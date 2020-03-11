# Simple Delegate pattern vs Closure pattern

> 지난 번에 조사했던 [Delegate pattern vs Closure pattern](https://velog.io/@wimes/Delegate-vs-Closure-Callbacks)을 토대로 한번 간단한 예제를 직접 만들어봤습니다.
>
> 아래의 예제는 HTTP GET 통신을 하는 예제입니다.

## Closure pattern

우선 Closure 패턴입니다.

### APIClient(통신)

`APIClient.swift`는 실제로 http와 통신하는 class입니다.

`completionHanlder` 파라미터를 탈출클로저로 받아오고 session을 실행시키는 모습입니다.

**APIClient.swift**

```swift
class APIClient{
  let session: URLSession = URLSession.shared
    
  //GET
  func get(url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void){
    var request: URLRequest = URLRequest(url: url)

    request.httpMethod = "GET"
    request.addValue("application/json", forHTTPHeaderField: "Accept")

    session.dataTask(with: request, completionHandler: completionHandler).resume()
  }
}		
```

### ContentView(UI 및 동작 호출)

`ContentView`  를 살펴보겠습니다.

딱히 특별한 것은 없고 Button을 누르게 되면 `requestClosure` 를 호출합니다.

**ContentView.swift**

```swift
import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: ContentViewModel = ContentViewModel()
    
    var body: some View {
        List{
            Button(action: self.requestClosure){
                Text("Request Closure")
            }
        }
    }
}
extension ContentView{
    func requestClosure(){
        self.viewModel.requestClosure()
    }
}
```



### ContentViewModel(통신 호출 및 처리 동작)

이제 `ContentViewModel` 을 한번 살펴보겠습니다.

ContentViewModel에서는 APIClient의 get 함수를 호출하면서 클로저를 채워줍니다.

if 구문을 통해 실패 성공을 나눠서 동작하도록 처리했습니다.

**ContentViewModel.swift**

```swift
class ContentViewModel: ObservableObject{
  let apiClient: APIClient = APIClient()
  
  func requestClosure(){
        print("requestClosure")
        let url: URL = URL(string: "\(Config.baseURL)/get")!
        
        apiClient.get(url: url, completionHandler: { data, res, err in
            if err == nil{
                if let d = data {
                    if let jsonString = String(data: d, encoding: .utf8){
                        if let dict = jsonStringToDictionary(jsonString: jsonString){
                            print(dict)
                            //doSomething
                        }
                    }
                }
            }else{
                if let err = err{
                    print(err)
                }
            }
        })
    }
}

```



## Delegate pattern

### APIHandler(통신 및 권한 정의)

Delegate pattern은 protocol을 만드는 데에서 시작합니다.

우리가 원하는 동작은 ContentView에서 호출을 하면 응답을 ContentViewModel에 오도록하는 것이 목적이며, ContentViewModel에서 결과값에 대한 핸들링을 위임합니다.

**APIHandler.swift**

```swift
protocol APIDelegate {
    func responseDelegate(jsonDict: [String: Any])
}

class APIHandler{
    var delegate: APIDelegate?
    let session: URLSession = URLSession.shared
    
    init(delegate: APIDelegate) {
        self.delegate = delegate
    }
    func get(){
          print("APIHandler.get()")
          let url: URL = URL(string: "\(Config.baseURL)/get")!
          var request: URLRequest = URLRequest(url: url)

          request.httpMethod = "GET"
          request.addValue("application/json", forHTTPHeaderField: "Accept")

          let task = self.session.dataTask(with: request){ data, res, err in
              if err == nil{
                  if let d = data {
                      if let jsonString = String(data: d, encoding: .utf8){
                          if let dict = jsonStringToDictionary(jsonString: jsonString){
  //                            print(dict)
                              //doSomething
                              self.requestDelegate(jsonDict: dict)
                          }
                      }
                  }
              }else{
                  if let err = err{
                      print(err)
                  }
              }
          }

          task.resume()
    }
    func requestDelegate(jsonDict: [String: Any]){
          self.delegate?.responseDelegate(jsonDict: jsonDict)
    }
}
```

차근차근 살펴보면 우선 `APIDelegate` 는 response를 받을 함수의 원형만을 정의합니다.(이 후에 ContentViewModel에 탑재될 것입니다.)

`APIHandler` 클래스는 delegate와 session이 있습니다.
delegate는 권한을 부여하기 위함이고
session은 통신의 목적입니다.

`get` 메소드는 session을 열어 통신을 수행합니다.
여기서 중요한 점은 `self.reqeustDelegate(jsonDict: dict)` 이부분인데 통신에 성공했다면
`requestDelegate(jsonDict:)`  메서드를 호출합니다.

`requestDelegate(jsonDict:)` 메서드의 하는 일은 **권한을 부여한 인스턴스의 `responseDelegate`를 호출**합니다.



### ContentView(UI 및 동작 호출)

`ContentView`  는 위의 Closure 패턴과 같으므로 생략하겠습니다.



### ContentViewModel(통신 호출 및 처리 동작 )

` ConentViewModel`입니다. 

ContentViewModel은 APIDelegate를 채택합니다.
실제로 통신의 권한을 위임받고 동작을 수행합니다.

```swift
class ContentViewModel: ObservableObject{
    let apiClient: APIClient = APIClient()
    var apiHandler: APIHandler? = nil
    
    init() {
        self.apiHandler = APIHandler(delegate: self)
    }
}

extension ContentViewModel: APIDelegate{
    //request
    func requestDelegate(){
        print("requestDelegate")
        self.apiHandler?.get()
    }
    
    //response
    func responseDelegate(jsonDict: [String : Any]) {
        print("responseDelegate")
        print(jsonDict)
    }
}
```

ContentViewModel의 인스턴스가 생성될 때 apiHandler에 자기자신을 넘겨줍니다.
권한을 넘겨받은 APIHandler에는 ContentViewModel에 대한 정보를 갖고 있습니다.

ContentView에서 버튼을 누르면 `requestDelegate` 메서드가 호출되는데 이 메서드가 하는 일은 `APIHandler` 의 `get()` 메서드를 호출합니다.

호출된 `get`메서드는 통신을 한 후 성공했다면 `APIHandler.reqeustDelegate(jsonDict:)` 메서드를 호출할 것이고
결정적으로 `ContentViewModel.responseDelegate(jsonDict:)` 을  호출 할 것입니다.



## 결론

구글링을 하면서 여러 아티클들을 봤지만 하나같이 closure 패턴이 더 좋다라는 평을 받았습니다.

제가 그들보다는 안목이 뛰어난건 아니지만 저의 주관으로는

closure패턴은

* 관련 메서드들이 하나의 클로저안에 모두 있기에 그 안에서만 처리할 수 있다는 **장점**이 있고
* **단점**은 자칫하면 콜백헬의 늪에 빠져들어서 읽기 불편한 코드가 될 수 있습니다.

delegate패턴은

* **단점**은 관련 메서드들이 중구난방으로 퍼져있어서 찾기가 어려울 수 있겠다는 생각이 들었습니다.
  * 하나의 reqeust-response가 서로 떼어져 있어서 코드를 보는 묶음이 조금 조잡해보였습니다.
  * 또한 구현하는데에 상대적으로 어려웠습니다.
  * 훗날 여러개의 호출 함수가 생긴다면 APIDelegate 프로토콜의 양이 많아지던가 새로운 Delegate 프로토콜을 만들어야 할지도 모른다는 생각이 들었습니다.
* **장점**은 request-response의 코드의 양이 실제로 동작을 처리하는 부분(ContentViewModel)에서 매우 짧았습니다.

아직 뭐가 더 좋다라고 명확하게는 말할 수는 없지만 저는 delegate pattern쪽이 보기에는 더 좋아보인다고 생각합니다.
closure 쪽은 callbackHell 문제만 완벽히 해결할 수 있다고하면 매우 강력할 것 같습니다.

