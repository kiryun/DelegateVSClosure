struct Todo {
    var id: Int
    var title: String
    
    var completed: Bool = false {
        didSet {
            // Notify subscribers of completion
            guard completed else { return }
            handlers.forEach { $0(self) }
        }
    }
    
    // Task queue
    var handlers = [(Todo) -> Void]()
    
    init(id: Int, title: String) {
        self.id = id
        self.title = title
    }
    
    mutating func subscribe(completion: @escaping (Todo) -> Void) {
        handlers += [completion]
    }
}

class MyParentController {
    lazy var todo1: Todo = {
        return Todo(id: 1, title: "Todo item 1")
    }()
    
    lazy var todo2: Todo = {
        return Todo(id: 2, title: "Todo item 2")
    }()
    
    lazy var todo3: Todo = {
        return Todo(id: 3, title: "Todo item 3")
    }()
}

let controller = MyParentController()

controller.todo1.subscribe {
    print("Do something with todo: \($0.title)")
}

controller.todo2.subscribe {
    print("Do another thing with todo: \($0.title)")
}

controller.todo3.subscribe {
    print("Do final thing with todo: \($0.title)")
}

controller.todo1.subscribe {
    print("Another one for fun with todo: \($0.title)")
}

controller.todo1.completed = true
controller.todo2.completed = true
controller.todo3.completed = true


// Do something with todo: Todo item 1
// Another one for fun with todo: Todo item 1
// Do another thing with todo: Todo item 1
// Do final thing with todo: Todo item 3
