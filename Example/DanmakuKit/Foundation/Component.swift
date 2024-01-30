//
//  Component.swift
//  DanmakuKit_Example
//
//  Created by Q YiZhong on 2023/3/5.
//

import Foundation

protocol Component: AnyObject {
    
    init(_ context: ComponentContext)
    
}

class WeakObject<T: AnyObject> {
    
    weak var value: T?
    
    init(_ value: T) {
        self.value = value
    }
    
}

class ComponentContext {
    
    var serviceInfo: [Int: WeakObject<AnyObject>] = [:]
    
    var eventInfo: [Int: [WeakObject<AnyObject>]] = [:]
    
    func register<Service>(service type: Service.Type, for object: AnyObject) {
        let key = Int(bitPattern: ObjectIdentifier(type))
        serviceInfo[key] = WeakObject(object)
    }
    
    func get<Service>(service type: Service.Type) -> Service {
        let key = Int(bitPattern: ObjectIdentifier(type))
        guard let service = serviceInfo[key]?.value as? Service else {
            fatalError("Cannot find service: \(type).")
        }
        return service
    }
    
    func `subscribe`<Event>(event type: Event.Type, for object: AnyObject) {
        let key = Int(bitPattern: ObjectIdentifier(type))
        var array = eventInfo[key]
        if array == nil {
            array = []
        }
        array?.append(WeakObject(object))
        eventInfo[key] = array
    }
    
    func send<Event>(event type: Event.Type, _ closure: (Event) -> Void) {
        let key = Int(bitPattern: ObjectIdentifier(type))
        let eventArray = eventInfo[key]?.map { return $0.value }
        let array: [Event]? = eventArray as? [Event]
        array?.forEach(closure)
    }
    
}

class ComponentCenter {
    
    let context: ComponentContext = ComponentContext()
    
    var components: [Component] = []
    
    func register(_ component: Component.Type) {
        components.append(component.init(context))
    }
    
}
