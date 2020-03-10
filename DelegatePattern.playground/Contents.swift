protocol BossDelegate{
    func manageTasks()
}

struct Secretary: BossDelegate{
    func manageTasks() {
        print("오늘 할일이 산더미")
    }
}

struct Assistance: BossDelegate{
    func manageTasks() {
        print("쉬엄 쉬엄")
    }
}

struct Boss{
    var delegate: BossDelegate
}

var boss = Boss(delegate: Secretary())
boss.delegate = Assistance()

boss.delegate.manageTasks() // 쉬엄 쉬엄


///
protocol TodoDelegate: class {
    func completed(todo: Todo)
}

struct Todo {
    var id: Int
    var title: String
    
    var completed: Bool = false {
        didSet {
            // Notify delegate of completion
            guard completed else { return }
            delegate?.completed(todo: self)
        }
    }
    
    weak var delegate : TodoDelegate?
    
    init(_ delegate: TodoDelegate, id: Int, title: String) {
        self.delegate = delegate
        self.id = id
        self.title = title
    }
}

class MyParentController: TodoDelegate {
    lazy var todo1: Todo = {
        return Todo(self, id: 1, title: "Todo item 1")
    }()
    
    lazy var todo2: Todo = {
        return Todo(self, id: 2, title: "Todo item 2")
    }()
    
    lazy var todo3: Todo = {
        return Todo(self, id: 3, title: "Todo item 3")
    }()
    
    func completed(todo: Todo) {
        switch todo.id {
        case 1: print("Do something with todo: \(todo.title)")
        case 2: print("Do another thing with todo: \(todo.title)")
        case 3: print("Do final thing with todo: \(todo.title)")
        default: break
        }
    }
}

let controller = MyParentController()
controller.todo1.completed = true
controller.todo2.completed = true
controller.todo3.completed = true

// Do something with todo: Todo item 1
// Do something with todo: Todo item 2
// Do final thing with todo: Todo item 3
