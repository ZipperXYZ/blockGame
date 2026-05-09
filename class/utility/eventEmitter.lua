require "class/superClass"

EventEmitter = SuperClass:extend()
EventEmitter.className = "EventEmitter"

function EventEmitter:init()
    self._callbacks = {}
end

function EventEmitter:on(callback)
    table.insert(self._callbacks, callback)
end

function EventEmitter:emit(...)
    for _, callback in ipairs(self._callbacks) do
        callback(...)
    end
end

function EventEmitter:off(callback)
    for i, cb in ipairs(self._callbacks) do
        if cb == callback then
            table.remove(self._callbacks, i)
            return
        end
    end
end
