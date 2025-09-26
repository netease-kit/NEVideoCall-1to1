'use strict';

Object.defineProperty(exports, '__esModule', { value: true });

/******************************************************************************
Copyright (c) Microsoft Corporation.

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
PERFORMANCE OF THIS SOFTWARE.
***************************************************************************** */
/* global Reflect, Promise */

var extendStatics = function(d, b) {
    extendStatics = Object.setPrototypeOf ||
        ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
        function (d, b) { for (var p in b) if (Object.prototype.hasOwnProperty.call(b, p)) d[p] = b[p]; };
    return extendStatics(d, b);
};

function __extends(d, b) {
    if (typeof b !== "function" && b !== null)
        throw new TypeError("Class extends value " + String(b) + " is not a constructor or null");
    extendStatics(d, b);
    function __() { this.constructor = d; }
    d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
}

var __assign = function() {
    __assign = Object.assign || function __assign(t) {
        for (var s, i = 1, n = arguments.length; i < n; i++) {
            s = arguments[i];
            for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p)) t[p] = s[p];
        }
        return t;
    };
    return __assign.apply(this, arguments);
};

function __awaiter(thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
}

function __generator(thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g;
    return g = { next: verb(0), "throw": verb(1), "return": verb(2) }, typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (_) try {
            if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [op[0] & 2, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
}

function __values(o) {
    var s = typeof Symbol === "function" && Symbol.iterator, m = s && o[s], i = 0;
    if (m) return m.call(o);
    if (o && typeof o.length === "number") return {
        next: function () {
            if (o && i >= o.length) o = void 0;
            return { value: o && o[i++], done: !o };
        }
    };
    throw new TypeError(s ? "Object is not iterable." : "Symbol.iterator is not defined.");
}

var SIGNAL_NULL = {
    code: '101',
    message: 'signal is null',
};
var CHANNELINFO_NULL = {
    code: '102',
    message: 'channelInfo is null',
};
var NOT_CALLING = {
    code: '103',
    message: 'not calling',
};
var NOT_BE_CALL = {
    code: '104',
    message: 'not be call',
};
var CALL_BUSY = {
    code: '105',
    message: 'be call busy',
};
var NOT_IN_CALL = {
    code: '106',
    message: 'not in call',
};
var CALLID_NOT_MATCH = {
    code: '106',
    message: 'callId not match',
};

// export type SignalControllerR
var SignalControllerCallingStatus;
(function (SignalControllerCallingStatus) {
    SignalControllerCallingStatus[SignalControllerCallingStatus["idle"] = 0] = "idle";
    SignalControllerCallingStatus[SignalControllerCallingStatus["calling"] = 1] = "calling";
    SignalControllerCallingStatus[SignalControllerCallingStatus["called"] = 2] = "called";
    SignalControllerCallingStatus[SignalControllerCallingStatus["inCall"] = 3] = "inCall";
})(SignalControllerCallingStatus || (SignalControllerCallingStatus = {}));

var commonjsGlobal = typeof globalThis !== 'undefined' ? globalThis : typeof window !== 'undefined' ? window : typeof global !== 'undefined' ? global : typeof self !== 'undefined' ? self : {};

function unwrapExports (x) {
	return x && x.__esModule && Object.prototype.hasOwnProperty.call(x, 'default') ? x['default'] : x;
}

function createCommonjsModule(fn, module) {
	return module = { exports: {} }, fn(module, module.exports), module.exports;
}

var loglevel = createCommonjsModule(function (module) {
/*
* loglevel - https://github.com/pimterry/loglevel
*
* Copyright (c) 2013 Tim Perry
* Licensed under the MIT license.
*/
(function (root, definition) {
    if (module.exports) {
        module.exports = definition();
    } else {
        root.log = definition();
    }
}(commonjsGlobal, function () {

    // Slightly dubious tricks to cut down minimized file size
    var noop = function() {};
    var undefinedType = "undefined";
    var isIE = (typeof window !== undefinedType) && (typeof window.navigator !== undefinedType) && (
        /Trident\/|MSIE /.test(window.navigator.userAgent)
    );

    var logMethods = [
        "trace",
        "debug",
        "info",
        "warn",
        "error"
    ];

    // Cross-browser bind equivalent that works at least back to IE6
    function bindMethod(obj, methodName) {
        var method = obj[methodName];
        if (typeof method.bind === 'function') {
            return method.bind(obj);
        } else {
            try {
                return Function.prototype.bind.call(method, obj);
            } catch (e) {
                // Missing bind shim or IE8 + Modernizr, fallback to wrapping
                return function() {
                    return Function.prototype.apply.apply(method, [obj, arguments]);
                };
            }
        }
    }

    // Trace() doesn't print the message in IE, so for that case we need to wrap it
    function traceForIE() {
        if (console.log) {
            if (console.log.apply) {
                console.log.apply(console, arguments);
            } else {
                // In old IE, native console methods themselves don't have apply().
                Function.prototype.apply.apply(console.log, [console, arguments]);
            }
        }
        if (console.trace) console.trace();
    }

    // Build the best logging method possible for this env
    // Wherever possible we want to bind, not wrap, to preserve stack traces
    function realMethod(methodName) {
        if (methodName === 'debug') {
            methodName = 'log';
        }

        if (typeof console === undefinedType) {
            return false; // No method possible, for now - fixed later by enableLoggingWhenConsoleArrives
        } else if (methodName === 'trace' && isIE) {
            return traceForIE;
        } else if (console[methodName] !== undefined) {
            return bindMethod(console, methodName);
        } else if (console.log !== undefined) {
            return bindMethod(console, 'log');
        } else {
            return noop;
        }
    }

    // These private functions always need `this` to be set properly

    function replaceLoggingMethods(level, loggerName) {
        /*jshint validthis:true */
        for (var i = 0; i < logMethods.length; i++) {
            var methodName = logMethods[i];
            this[methodName] = (i < level) ?
                noop :
                this.methodFactory(methodName, level, loggerName);
        }

        // Define log.log as an alias for log.debug
        this.log = this.debug;
    }

    // In old IE versions, the console isn't present until you first open it.
    // We build realMethod() replacements here that regenerate logging methods
    function enableLoggingWhenConsoleArrives(methodName, level, loggerName) {
        return function () {
            if (typeof console !== undefinedType) {
                replaceLoggingMethods.call(this, level, loggerName);
                this[methodName].apply(this, arguments);
            }
        };
    }

    // By default, we use closely bound real methods wherever possible, and
    // otherwise we wait for a console to appear, and then try again.
    function defaultMethodFactory(methodName, level, loggerName) {
        /*jshint validthis:true */
        return realMethod(methodName) ||
               enableLoggingWhenConsoleArrives.apply(this, arguments);
    }

    function Logger(name, defaultLevel, factory) {
      var self = this;
      var currentLevel;
      defaultLevel = defaultLevel == null ? "WARN" : defaultLevel;

      var storageKey = "loglevel";
      if (typeof name === "string") {
        storageKey += ":" + name;
      } else if (typeof name === "symbol") {
        storageKey = undefined;
      }

      function persistLevelIfPossible(levelNum) {
          var levelName = (logMethods[levelNum] || 'silent').toUpperCase();

          if (typeof window === undefinedType || !storageKey) return;

          // Use localStorage if available
          try {
              window.localStorage[storageKey] = levelName;
              return;
          } catch (ignore) {}

          // Use session cookie as fallback
          try {
              window.document.cookie =
                encodeURIComponent(storageKey) + "=" + levelName + ";";
          } catch (ignore) {}
      }

      function getPersistedLevel() {
          var storedLevel;

          if (typeof window === undefinedType || !storageKey) return;

          try {
              storedLevel = window.localStorage[storageKey];
          } catch (ignore) {}

          // Fallback to cookies if local storage gives us nothing
          if (typeof storedLevel === undefinedType) {
              try {
                  var cookie = window.document.cookie;
                  var location = cookie.indexOf(
                      encodeURIComponent(storageKey) + "=");
                  if (location !== -1) {
                      storedLevel = /^([^;]+)/.exec(cookie.slice(location))[1];
                  }
              } catch (ignore) {}
          }

          // If the stored level is not valid, treat it as if nothing was stored.
          if (self.levels[storedLevel] === undefined) {
              storedLevel = undefined;
          }

          return storedLevel;
      }

      function clearPersistedLevel() {
          if (typeof window === undefinedType || !storageKey) return;

          // Use localStorage if available
          try {
              window.localStorage.removeItem(storageKey);
              return;
          } catch (ignore) {}

          // Use session cookie as fallback
          try {
              window.document.cookie =
                encodeURIComponent(storageKey) + "=; expires=Thu, 01 Jan 1970 00:00:00 UTC";
          } catch (ignore) {}
      }

      /*
       *
       * Public logger API - see https://github.com/pimterry/loglevel for details
       *
       */

      self.name = name;

      self.levels = { "TRACE": 0, "DEBUG": 1, "INFO": 2, "WARN": 3,
          "ERROR": 4, "SILENT": 5};

      self.methodFactory = factory || defaultMethodFactory;

      self.getLevel = function () {
          return currentLevel;
      };

      self.setLevel = function (level, persist) {
          if (typeof level === "string" && self.levels[level.toUpperCase()] !== undefined) {
              level = self.levels[level.toUpperCase()];
          }
          if (typeof level === "number" && level >= 0 && level <= self.levels.SILENT) {
              currentLevel = level;
              if (persist !== false) {  // defaults to true
                  persistLevelIfPossible(level);
              }
              replaceLoggingMethods.call(self, level, name);
              if (typeof console === undefinedType && level < self.levels.SILENT) {
                  return "No console available for logging";
              }
          } else {
              throw "log.setLevel() called with invalid level: " + level;
          }
      };

      self.setDefaultLevel = function (level) {
          defaultLevel = level;
          if (!getPersistedLevel()) {
              self.setLevel(level, false);
          }
      };

      self.resetLevel = function () {
          self.setLevel(defaultLevel, false);
          clearPersistedLevel();
      };

      self.enableAll = function(persist) {
          self.setLevel(self.levels.TRACE, persist);
      };

      self.disableAll = function(persist) {
          self.setLevel(self.levels.SILENT, persist);
      };

      // Initialize with the right level
      var initialLevel = getPersistedLevel();
      if (initialLevel == null) {
          initialLevel = defaultLevel;
      }
      self.setLevel(initialLevel, false);
    }

    /*
     *
     * Top-level API
     *
     */

    var defaultLogger = new Logger();

    var _loggersByName = {};
    defaultLogger.getLogger = function getLogger(name) {
        if ((typeof name !== "symbol" && typeof name !== "string") || name === "") {
          throw new TypeError("You must supply a name when creating a logger.");
        }

        var logger = _loggersByName[name];
        if (!logger) {
          logger = _loggersByName[name] = new Logger(
            name, defaultLogger.getLevel(), defaultLogger.methodFactory);
        }
        return logger;
    };

    // Grab the current global log variable in case of overwrite
    var _log = (typeof window !== undefinedType) ? window.log : undefined;
    defaultLogger.noConflict = function() {
        if (typeof window !== undefinedType &&
               window.log === defaultLogger) {
            window.log = _log;
        }

        return defaultLogger;
    };

    defaultLogger.getLoggers = function getLoggers() {
        return _loggersByName;
    };

    // ES6 default export, for compatibility
    defaultLogger['default'] = defaultLogger;

    return defaultLogger;
}));
});

var c=function(n){var t=void 0===n?{appName:"",version:"",storeWindow:!1}:n,r=t.level,o=t.appName,a=void 0===o?"":o,c=t.version,l=void 0===c?"":c,u=t.storeWindow,i=void 0!==u&&u,s=function(){var e=new Date,n=e.getFullYear(),t=e.getMonth()+1,r=e.getDate(),o=e.getHours()<10?"0".concat(e.getHours()):e.getHours(),a=e.getMinutes()<10?"0".concat(e.getMinutes()):e.getMinutes(),c=e.getSeconds()<10?"0".concat(e.getSeconds()):e.getSeconds();return "".concat(n,"-").concat(t,"-").concat(r," ").concat(o,":").concat(a,":").concat(c)},f=new Proxy(loglevel,{get:function(e,n){if(n in e){var t=e[n];if(!["log","info","warn","error","trace","debug"].includes(n))return t;var r=function(){try{var e=navigator.userAgent.toLocaleLowerCase().match(/(msie|firefox|chrome|opera|version).*?([\d.]+)/)||[];return {browser:e[1].replace(/version/,"safari"),ver:e[2]}}catch(e){return null}}(),o="";return o=r?"[ ".concat(a," ").concat(l," ").concat(r.browser,":").concat(r.ver," ").concat(s()," ]"):"[ ".concat(a," ").concat(l," ").concat(s()," ]"),t.bind(null,o)}}});return r&&f.setLevel(r),i&&(window.__LOGGER__=f),f};

var eventemitter3 = createCommonjsModule(function (module) {

var has = Object.prototype.hasOwnProperty
  , prefix = '~';

/**
 * Constructor to create a storage for our `EE` objects.
 * An `Events` instance is a plain object whose properties are event names.
 *
 * @constructor
 * @private
 */
function Events() {}

//
// We try to not inherit from `Object.prototype`. In some engines creating an
// instance in this way is faster than calling `Object.create(null)` directly.
// If `Object.create(null)` is not supported we prefix the event names with a
// character to make sure that the built-in object properties are not
// overridden or used as an attack vector.
//
if (Object.create) {
  Events.prototype = Object.create(null);

  //
  // This hack is needed because the `__proto__` property is still inherited in
  // some old browsers like Android 4, iPhone 5.1, Opera 11 and Safari 5.
  //
  if (!new Events().__proto__) prefix = false;
}

/**
 * Representation of a single event listener.
 *
 * @param {Function} fn The listener function.
 * @param {*} context The context to invoke the listener with.
 * @param {Boolean} [once=false] Specify if the listener is a one-time listener.
 * @constructor
 * @private
 */
function EE(fn, context, once) {
  this.fn = fn;
  this.context = context;
  this.once = once || false;
}

/**
 * Add a listener for a given event.
 *
 * @param {EventEmitter} emitter Reference to the `EventEmitter` instance.
 * @param {(String|Symbol)} event The event name.
 * @param {Function} fn The listener function.
 * @param {*} context The context to invoke the listener with.
 * @param {Boolean} once Specify if the listener is a one-time listener.
 * @returns {EventEmitter}
 * @private
 */
function addListener(emitter, event, fn, context, once) {
  if (typeof fn !== 'function') {
    throw new TypeError('The listener must be a function');
  }

  var listener = new EE(fn, context || emitter, once)
    , evt = prefix ? prefix + event : event;

  if (!emitter._events[evt]) emitter._events[evt] = listener, emitter._eventsCount++;
  else if (!emitter._events[evt].fn) emitter._events[evt].push(listener);
  else emitter._events[evt] = [emitter._events[evt], listener];

  return emitter;
}

/**
 * Clear event by name.
 *
 * @param {EventEmitter} emitter Reference to the `EventEmitter` instance.
 * @param {(String|Symbol)} evt The Event name.
 * @private
 */
function clearEvent(emitter, evt) {
  if (--emitter._eventsCount === 0) emitter._events = new Events();
  else delete emitter._events[evt];
}

/**
 * Minimal `EventEmitter` interface that is molded against the Node.js
 * `EventEmitter` interface.
 *
 * @constructor
 * @public
 */
function EventEmitter() {
  this._events = new Events();
  this._eventsCount = 0;
}

/**
 * Return an array listing the events for which the emitter has registered
 * listeners.
 *
 * @returns {Array}
 * @public
 */
EventEmitter.prototype.eventNames = function eventNames() {
  var names = []
    , events
    , name;

  if (this._eventsCount === 0) return names;

  for (name in (events = this._events)) {
    if (has.call(events, name)) names.push(prefix ? name.slice(1) : name);
  }

  if (Object.getOwnPropertySymbols) {
    return names.concat(Object.getOwnPropertySymbols(events));
  }

  return names;
};

/**
 * Return the listeners registered for a given event.
 *
 * @param {(String|Symbol)} event The event name.
 * @returns {Array} The registered listeners.
 * @public
 */
EventEmitter.prototype.listeners = function listeners(event) {
  var evt = prefix ? prefix + event : event
    , handlers = this._events[evt];

  if (!handlers) return [];
  if (handlers.fn) return [handlers.fn];

  for (var i = 0, l = handlers.length, ee = new Array(l); i < l; i++) {
    ee[i] = handlers[i].fn;
  }

  return ee;
};

/**
 * Return the number of listeners listening to a given event.
 *
 * @param {(String|Symbol)} event The event name.
 * @returns {Number} The number of listeners.
 * @public
 */
EventEmitter.prototype.listenerCount = function listenerCount(event) {
  var evt = prefix ? prefix + event : event
    , listeners = this._events[evt];

  if (!listeners) return 0;
  if (listeners.fn) return 1;
  return listeners.length;
};

/**
 * Calls each of the listeners registered for a given event.
 *
 * @param {(String|Symbol)} event The event name.
 * @returns {Boolean} `true` if the event had listeners, else `false`.
 * @public
 */
EventEmitter.prototype.emit = function emit(event, a1, a2, a3, a4, a5) {
  var evt = prefix ? prefix + event : event;

  if (!this._events[evt]) return false;

  var listeners = this._events[evt]
    , len = arguments.length
    , args
    , i;

  if (listeners.fn) {
    if (listeners.once) this.removeListener(event, listeners.fn, undefined, true);

    switch (len) {
      case 1: return listeners.fn.call(listeners.context), true;
      case 2: return listeners.fn.call(listeners.context, a1), true;
      case 3: return listeners.fn.call(listeners.context, a1, a2), true;
      case 4: return listeners.fn.call(listeners.context, a1, a2, a3), true;
      case 5: return listeners.fn.call(listeners.context, a1, a2, a3, a4), true;
      case 6: return listeners.fn.call(listeners.context, a1, a2, a3, a4, a5), true;
    }

    for (i = 1, args = new Array(len -1); i < len; i++) {
      args[i - 1] = arguments[i];
    }

    listeners.fn.apply(listeners.context, args);
  } else {
    var length = listeners.length
      , j;

    for (i = 0; i < length; i++) {
      if (listeners[i].once) this.removeListener(event, listeners[i].fn, undefined, true);

      switch (len) {
        case 1: listeners[i].fn.call(listeners[i].context); break;
        case 2: listeners[i].fn.call(listeners[i].context, a1); break;
        case 3: listeners[i].fn.call(listeners[i].context, a1, a2); break;
        case 4: listeners[i].fn.call(listeners[i].context, a1, a2, a3); break;
        default:
          if (!args) for (j = 1, args = new Array(len -1); j < len; j++) {
            args[j - 1] = arguments[j];
          }

          listeners[i].fn.apply(listeners[i].context, args);
      }
    }
  }

  return true;
};

/**
 * Add a listener for a given event.
 *
 * @param {(String|Symbol)} event The event name.
 * @param {Function} fn The listener function.
 * @param {*} [context=this] The context to invoke the listener with.
 * @returns {EventEmitter} `this`.
 * @public
 */
EventEmitter.prototype.on = function on(event, fn, context) {
  return addListener(this, event, fn, context, false);
};

/**
 * Add a one-time listener for a given event.
 *
 * @param {(String|Symbol)} event The event name.
 * @param {Function} fn The listener function.
 * @param {*} [context=this] The context to invoke the listener with.
 * @returns {EventEmitter} `this`.
 * @public
 */
EventEmitter.prototype.once = function once(event, fn, context) {
  return addListener(this, event, fn, context, true);
};

/**
 * Remove the listeners of a given event.
 *
 * @param {(String|Symbol)} event The event name.
 * @param {Function} fn Only remove the listeners that match this function.
 * @param {*} context Only remove the listeners that have this context.
 * @param {Boolean} once Only remove one-time listeners.
 * @returns {EventEmitter} `this`.
 * @public
 */
EventEmitter.prototype.removeListener = function removeListener(event, fn, context, once) {
  var evt = prefix ? prefix + event : event;

  if (!this._events[evt]) return this;
  if (!fn) {
    clearEvent(this, evt);
    return this;
  }

  var listeners = this._events[evt];

  if (listeners.fn) {
    if (
      listeners.fn === fn &&
      (!once || listeners.once) &&
      (!context || listeners.context === context)
    ) {
      clearEvent(this, evt);
    }
  } else {
    for (var i = 0, events = [], length = listeners.length; i < length; i++) {
      if (
        listeners[i].fn !== fn ||
        (once && !listeners[i].once) ||
        (context && listeners[i].context !== context)
      ) {
        events.push(listeners[i]);
      }
    }

    //
    // Reset the array, or remove it completely if we have no more listeners.
    //
    if (events.length) this._events[evt] = events.length === 1 ? events[0] : events;
    else clearEvent(this, evt);
  }

  return this;
};

/**
 * Remove all listeners, or those of the specified event.
 *
 * @param {(String|Symbol)} [event] The event name.
 * @returns {EventEmitter} `this`.
 * @public
 */
EventEmitter.prototype.removeAllListeners = function removeAllListeners(event) {
  var evt;

  if (event) {
    evt = prefix ? prefix + event : event;
    if (this._events[evt]) clearEvent(this, evt);
  } else {
    this._events = new Events();
    this._eventsCount = 0;
  }

  return this;
};

//
// Alias methods names because people roll like that.
//
EventEmitter.prototype.off = EventEmitter.prototype.removeListener;
EventEmitter.prototype.addListener = EventEmitter.prototype.on;

//
// Expose the prefix.
//
EventEmitter.prefixed = prefix;

//
// Allow `EventEmitter` to be imported as module namespace.
//
EventEmitter.EventEmitter = EventEmitter;

//
// Expose the module.
//
{
  module.exports = EventEmitter;
}
});

function uuidv4() {
    if (typeof crypto !== 'undefined') {
        return crypto.randomUUID();
    }
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
        var r = (Math.random() * 16) | 0, v = c == 'x' ? r : (r & 0x3) | 0x8;
        return v.toString(16);
    });
}
function formatMembers(members) {
    var AvSignalMemberInfo = {
        1: 'accid',
        2: 'uid',
        3: 'createTime',
        4: 'expireTime',
        5: 'web_uid',
    };
    var parseAvSignalMember = function (member) {
        var memberParsed = {};
        Object.keys(member).forEach(function (key) {
            memberParsed[AvSignalMemberInfo[key]] = member[key];
        });
        return memberParsed;
    };
    if (typeof members === 'string') {
        members = JSON.parse(members).map(function (member) {
            return parseAvSignalMember(member);
        });
    }
    return members;
}
var TAG_NAME = 'SignalController';
var SignalController = /** @class */ (function (_super) {
    __extends(SignalController, _super);
    /**
     *
     * @param im im实例对象
     * @param kitName 上层kit名称
     * @param version 上层kit版本
     * @param debug 是否开启debug，输出日志
     */
    function SignalController(_a) {
        var nim = _a.nim, _b = _a.enableAutoJoinSignalChannel, enableAutoJoinSignalChannel = _b === void 0 ? false : _b, kitName = _a.kitName, kitVersion = _a.kitVersion, _c = _a.debug, debug = _c === void 0 ? true : _c, uid = _a.uid;
        var _this = _super.call(this) || this;
        _this.callStatus = SignalControllerCallingStatus.idle; // 通话状态
        _this.costTime = {
            create: 0,
            join: 0,
            invite: 0,
            cost: 0,
            accept: 0,
        };
        _this._version = '0.0.0';
        _this._offlineEnabled = true;
        if (debug) {
            _this._logger = c({
                appName: kitName,
                version: kitVersion,
                level: 'trace',
            });
        }
        _this._signal = nim;
        _this._enableAutoJoinSignalChannel = enableAutoJoinSignalChannel;
        _this._uid = uid;
        _this._version = kitVersion;
        // 增加监听
        _this._addSignaladdEventListener();
        // 获取离线消息
        _this._signal.signalingSync();
        // 增加信令保活机制
        setInterval(function () {
            var _a;
            var channelId = (_a = _this._channelInfo) === null || _a === void 0 ? void 0 : _a.channelId;
            if (channelId) {
                _this._signal.signalingDelay({
                    channelId: channelId,
                });
            }
        }, 2 * 60 * 1000);
        return _this;
    }
    SignalController.prototype.call = function (params) {
        var _a, _b;
        return __awaiter(this, void 0, void 0, function () {
            var _c, error_1;
            return __generator(this, function (_d) {
                switch (_d.label) {
                    case 0:
                        // 日志
                        (_a = this._logger) === null || _a === void 0 ? void 0 : _a.info(TAG_NAME, 'call', params);
                        // 埋点
                        this.costTime.cost = Date.now();
                        if (!this._signal) {
                            throw SIGNAL_NULL;
                        }
                        if (this.callStatus !== SignalControllerCallingStatus.idle) {
                            throw CALL_BUSY;
                        }
                        _d.label = 1;
                    case 1:
                        _d.trys.push([1, 3, , 4]);
                        this._offlineEnabled = (_b = params.enableOffline) !== null && _b !== void 0 ? _b : true;
                        _c = this;
                        return [4 /*yield*/, this._signalCallEx(params)];
                    case 2:
                        _c._channelInfo = _d.sent();
                        return [2 /*return*/, this._channelInfo];
                    case 3:
                        error_1 = _d.sent();
                        throw error_1;
                    case 4: return [2 /*return*/];
                }
            });
        });
    };
    /**
     * 接受呼叫
     * @param params
     */
    SignalController.prototype.accept = function (opt) {
        var _a, _b, _c;
        return __awaiter(this, void 0, void 0, function () {
            var _d, channelId, requestId, callerId, attachExt, error_2;
            return __generator(this, function (_e) {
                switch (_e.label) {
                    case 0:
                        // 日志
                        (_a = this._logger) === null || _a === void 0 ? void 0 : _a.info(TAG_NAME, 'accept', opt);
                        _e.label = 1;
                    case 1:
                        _e.trys.push([1, 3, , 4]);
                        if (!this._channelInfo) {
                            throw CHANNELINFO_NULL;
                        }
                        if (this.callStatus !== SignalControllerCallingStatus.called) {
                            throw NOT_BE_CALL;
                        }
                        if ((opt === null || opt === void 0 ? void 0 : opt.callId) && ((_b = this._channelInfo) === null || _b === void 0 ? void 0 : _b.attachExt.callId) !== opt.callId) {
                            throw CALLID_NOT_MATCH;
                        }
                        this._offlineEnabled = (_c = opt === null || opt === void 0 ? void 0 : opt.enableOffline) !== null && _c !== void 0 ? _c : true;
                        _d = this._channelInfo, channelId = _d.channelId, requestId = _d.requestId, callerId = _d.callerId, attachExt = _d.attachExt;
                        return [4 /*yield*/, this._signalAccept({
                                channelId: channelId,
                                requestId: requestId,
                                account: callerId,
                                attachExt: attachExt,
                                nertcJoinRoomQueryParamMap: opt === null || opt === void 0 ? void 0 : opt.nertcJoinRoomQueryParamMap,
                            })];
                    case 2:
                        _e.sent();
                        return [2 /*return*/, this._channelInfo];
                    case 3:
                        error_2 = _e.sent();
                        throw error_2;
                    case 4: return [2 /*return*/];
                }
            });
        });
    };
    SignalController.prototype.cancel = function (opt) {
        var _a, _b, _c;
        return __awaiter(this, void 0, void 0, function () {
            var _d, channelId, requestId, calleeId, attachExt, error_3;
            return __generator(this, function (_e) {
                switch (_e.label) {
                    case 0:
                        // 日志
                        (_a = this._logger) === null || _a === void 0 ? void 0 : _a.info(TAG_NAME, 'cancel', opt);
                        _e.label = 1;
                    case 1:
                        _e.trys.push([1, 3, , 4]);
                        if (!this._channelInfo) {
                            throw CHANNELINFO_NULL;
                        }
                        if (this.callStatus !== SignalControllerCallingStatus.calling) {
                            throw NOT_CALLING;
                        }
                        if ((opt === null || opt === void 0 ? void 0 : opt.callId) && ((_b = this._channelInfo) === null || _b === void 0 ? void 0 : _b.attachExt.callId) !== opt.callId) {
                            throw CALLID_NOT_MATCH;
                        }
                        this._offlineEnabled = (_c = opt === null || opt === void 0 ? void 0 : opt.enableOffline) !== null && _c !== void 0 ? _c : true;
                        _d = this._channelInfo, channelId = _d.channelId, requestId = _d.requestId, calleeId = _d.calleeId, attachExt = _d.attachExt;
                        return [4 /*yield*/, this._signalCancel({
                                channelId: channelId,
                                requestId: requestId,
                                account: calleeId,
                                attachExt: attachExt,
                            })];
                    case 2:
                        _e.sent();
                        return [3 /*break*/, 4];
                    case 3:
                        error_3 = _e.sent();
                        throw error_3;
                    case 4: return [2 /*return*/];
                }
            });
        });
    };
    SignalController.prototype.reject = function (opt) {
        var _a, _b, _c, _d;
        return __awaiter(this, void 0, void 0, function () {
            var _e, channelId, attachExt, callerId, requestId, error_4;
            return __generator(this, function (_f) {
                switch (_f.label) {
                    case 0:
                        // 日志
                        (_a = this._logger) === null || _a === void 0 ? void 0 : _a.info(TAG_NAME, 'reject', opt);
                        _f.label = 1;
                    case 1:
                        _f.trys.push([1, 3, , 4]);
                        if (this.callStatus !== SignalControllerCallingStatus.called) {
                            throw NOT_BE_CALL;
                        }
                        if ((opt === null || opt === void 0 ? void 0 : opt.callId) && ((_b = this._channelInfo) === null || _b === void 0 ? void 0 : _b.attachExt.callId) !== opt.callId) {
                            throw CALLID_NOT_MATCH;
                        }
                        if (!this._channelInfo) {
                            throw CHANNELINFO_NULL;
                        }
                        this._offlineEnabled = (_c = opt === null || opt === void 0 ? void 0 : opt.enableOffline) !== null && _c !== void 0 ? _c : true;
                        _e = this._channelInfo, channelId = _e.channelId, attachExt = _e.attachExt, callerId = _e.callerId, requestId = _e.requestId;
                        attachExt.reason = (_d = opt === null || opt === void 0 ? void 0 : opt.reason) !== null && _d !== void 0 ? _d : 0;
                        return [4 /*yield*/, this._signalReject({
                                channelId: channelId,
                                requestId: requestId,
                                account: callerId,
                                attachExt: attachExt,
                            })];
                    case 2:
                        _f.sent();
                        return [3 /*break*/, 4];
                    case 3:
                        error_4 = _f.sent();
                        throw error_4;
                    case 4: return [2 /*return*/];
                }
            });
        });
    };
    /**
     * 挂断，同时挂断其他人
     */
    SignalController.prototype.hangup = function (opt) {
        var _a, _b, _c;
        return __awaiter(this, void 0, void 0, function () {
            var error_5;
            return __generator(this, function (_d) {
                switch (_d.label) {
                    case 0:
                        // 日志
                        (_a = this._logger) === null || _a === void 0 ? void 0 : _a.info(TAG_NAME, 'hangup', opt);
                        _d.label = 1;
                    case 1:
                        _d.trys.push([1, 3, , 4]);
                        if (this.callStatus !== SignalControllerCallingStatus.inCall) {
                            throw NOT_IN_CALL;
                        }
                        if ((opt === null || opt === void 0 ? void 0 : opt.callId) && ((_b = this._channelInfo) === null || _b === void 0 ? void 0 : _b.attachExt.callId) !== opt.callId) {
                            throw CALLID_NOT_MATCH;
                        }
                        this._offlineEnabled = (_c = opt === null || opt === void 0 ? void 0 : opt.enableOffline) !== null && _c !== void 0 ? _c : true;
                        return [4 /*yield*/, this._signalClose()];
                    case 2:
                        _d.sent();
                        this.emit('afterSignalHangup');
                        return [3 /*break*/, 4];
                    case 3:
                        error_5 = _d.sent();
                        throw error_5;
                    case 4: return [2 /*return*/];
                }
            });
        });
    };
    /**
     * 发送信息
     */
    SignalController.prototype.control = function (opt) {
        var _a, _b, _c;
        return __awaiter(this, void 0, void 0, function () {
            var error_6;
            return __generator(this, function (_d) {
                switch (_d.label) {
                    case 0:
                        // 日志
                        (_a = this._logger) === null || _a === void 0 ? void 0 : _a.info(TAG_NAME, 'control', opt);
                        _d.label = 1;
                    case 1:
                        _d.trys.push([1, 3, , 4]);
                        if (!this._channelInfo) {
                            throw CHANNELINFO_NULL;
                        }
                        if ((opt === null || opt === void 0 ? void 0 : opt.callId) && this._channelInfo.attachExt.callId !== opt.callId) {
                            throw CALLID_NOT_MATCH;
                        }
                        return [4 /*yield*/, this._signal.signalingControl({
                                channelId: this._channelInfo.channelId,
                                account: '',
                                attachExt: JSON.stringify(__assign(__assign({}, this._channelInfo.attachExt), opt === null || opt === void 0 ? void 0 : opt.ext)),
                            })
                            // 日志
                        ];
                    case 2:
                        _d.sent();
                        // 日志
                        (_b = this._logger) === null || _b === void 0 ? void 0 : _b.log(TAG_NAME, 'control success');
                        return [3 /*break*/, 4];
                    case 3:
                        error_6 = _d.sent();
                        // 日志
                        (_c = this._logger) === null || _c === void 0 ? void 0 : _c.error(TAG_NAME, 'control fail', error_6);
                        throw error_6;
                    case 4: return [2 /*return*/];
                }
            });
        });
    };
    SignalController.prototype.reconnect = function () {
        var _a;
        // 日志
        (_a = this._logger) === null || _a === void 0 ? void 0 : _a.info(TAG_NAME, 'reconnect');
        // 获取离线消息
        this._signal.signalingSync();
    };
    SignalController.prototype.resetState = function () {
        this._channelInfo = undefined;
        this.callStatus = SignalControllerCallingStatus.idle;
        this._callTimer && clearTimeout(this._callTimer);
        this._rejectTimer && clearTimeout(this._rejectTimer);
        // 埋点统计
        this.costTime = {
            create: 0,
            join: 0,
            invite: 0,
            accept: 0,
            cost: 0,
        };
    };
    SignalController.prototype.destroy = function () {
        var _a, _b, _c, _d;
        // 日志
        (_a = this._logger) === null || _a === void 0 ? void 0 : _a.info(TAG_NAME, 'destroy');
        this.resetState();
        (_b = this._signal) === null || _b === void 0 ? void 0 : _b.off('signalingNotify');
        (_c = this._signal) === null || _c === void 0 ? void 0 : _c.off('signalingMutilClientSyncNotify');
        (_d = this._signal) === null || _d === void 0 ? void 0 : _d.off('signalingUnreadMessageSyncNotify');
    };
    SignalController.prototype._signalCallEx = function (params) {
        var _a, _b;
        return __awaiter(this, void 0, void 0, function () {
            var attachExt, signalingCallExParams, channelInfo, error_7;
            var _this = this;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0:
                        _c.trys.push([0, 2, , 3]);
                        attachExt = {
                            callId: params.callId || uuidv4(),
                            channelName: params.nertcChannelName || "".concat(uuidv4()),
                            rtcTokenTtl: params.nertcTokenTtl || 500,
                            version: this._version,
                            callType: 0,
                            global_extra: params.globalExtraCopy,
                            extraInfo: params.extraInfo,
                            _attachment: params.extraInfo,
                            reason: 0,
                        };
                        signalingCallExParams = {
                            uid: this._uid,
                            offlineEnabled: this._offlineEnabled,
                            account: params.accId,
                            channelName: params.signalChannelName,
                            type: params.callType,
                            requestId: uuidv4(),
                            attachExt: JSON.stringify(attachExt),
                            nertcChannelName: attachExt.channelName,
                            nertcTokenTtl: params.nertcTokenTtl,
                            nertcJoinRoomQueryParamMap: params.nertcJoinRoomQueryParamMap,
                            pushInfo: params.signalPushConfig || {
                                pushTitle: '邀请通知',
                                pushContent: '你收到了邀请',
                                pushPayload: '{}',
                                needPush: true,
                                needBadge: true,
                            },
                        };
                        // 埋点
                        this.costTime.invite = Date.now();
                        return [4 /*yield*/, this._signal.signalingCallEx(signalingCallExParams)];
                    case 1:
                        channelInfo = (_c.sent());
                        // 补充channelInfo信息
                        this.costTime.invite = Date.now() - this.costTime.invite;
                        channelInfo.calleeId = signalingCallExParams.account;
                        channelInfo.requestId = signalingCallExParams.requestId;
                        channelInfo.members = formatMembers(channelInfo.members);
                        channelInfo.attachExt = attachExt;
                        this.callStatus = SignalControllerCallingStatus.calling;
                        // 埋点
                        this.costTime.cost = Date.now() - this.costTime.cost;
                        // 日志
                        (_a = this._logger) === null || _a === void 0 ? void 0 : _a.log(TAG_NAME, 'signalingCallEx success', channelInfo);
                        this.emit('afterSignalCallEx', channelInfo);
                        // 超时取消
                        if (this.callTimeout) {
                            this._callTimer = setTimeout(function () { return __awaiter(_this, void 0, void 0, function () {
                                var _a, channelId, requestId, calleeId, attachExt_1, error_8;
                                var _b, _c;
                                return __generator(this, function (_d) {
                                    switch (_d.label) {
                                        case 0:
                                            if (!(this.callStatus === SignalControllerCallingStatus.calling &&
                                                this._channelInfo)) return [3 /*break*/, 4];
                                            this._channelInfo.attachExt.reason = 2;
                                            _a = this._channelInfo, channelId = _a.channelId, requestId = _a.requestId, calleeId = _a.calleeId, attachExt_1 = _a.attachExt;
                                            _d.label = 1;
                                        case 1:
                                            _d.trys.push([1, 3, , 4]);
                                            return [4 /*yield*/, this._signalCancel({
                                                    channelId: channelId,
                                                    requestId: requestId,
                                                    account: calleeId,
                                                    attachExt: attachExt_1,
                                                })
                                                // 日志
                                            ];
                                        case 2:
                                            _d.sent();
                                            // 日志
                                            (_b = this._logger) === null || _b === void 0 ? void 0 : _b.log(TAG_NAME, 'signalInvite timeout cancel success', this.callTimeout);
                                            return [3 /*break*/, 4];
                                        case 3:
                                            error_8 = _d.sent();
                                            // 日志
                                            (_c = this._logger) === null || _c === void 0 ? void 0 : _c.error(TAG_NAME, 'signalInvite timeout cancel fail', error_8, this.callTimeout);
                                            return [3 /*break*/, 4];
                                        case 4: return [2 /*return*/];
                                    }
                                });
                            }); }, this.callTimeout);
                        }
                        return [2 /*return*/, channelInfo];
                    case 2:
                        error_7 = _c.sent();
                        // 日志
                        (_b = this._logger) === null || _b === void 0 ? void 0 : _b.error(TAG_NAME, 'signalingCallEx fail', error_7);
                        throw error_7;
                    case 3: return [2 /*return*/];
                }
            });
        });
    };
    SignalController.prototype._addSignaladdEventListener = function () {
        var _this = this;
        var _a;
        var handleSignalEvent = function (event) { return __awaiter(_this, void 0, void 0, function () {
            var _a, _b;
            return __generator(this, function (_c) {
                this._batchMarkEvent([event]);
                // 当本端已经建立信令连接后，不是本个信令房间内的消息不处理
                if (event.eventType !== 'INVITE' &&
                    event.channelId !== ((_a = this._channelInfo) === null || _a === void 0 ? void 0 : _a.channelId)) {
                    return [2 /*return*/];
                }
                // 日志
                (_b = this._logger) === null || _b === void 0 ? void 0 : _b.log(TAG_NAME, 'handleSignalEvent', event.eventType, event);
                switch (event.eventType) {
                    case 'ROOM_JOIN':
                        this._signalRoomJoinHandler(event);
                        break;
                    case 'ROOM_CLOSE':
                        this._roomCloseHandler(event);
                        break;
                    case 'LEAVE':
                        // this.signalLeaveHandler(event)
                        break;
                    case 'INVITE':
                        this._inviteHandler(event);
                        break;
                    case 'CANCEL_INVITE':
                        this._cancelInviteHandler(event);
                        break;
                    case 'REJECT':
                        this._rejectHandler(event);
                        break;
                    case 'ACCEPT':
                        this._acceptHandler(event);
                        break;
                    case 'CONTROL':
                        this._controlHandler(event);
                        break;
                }
                return [2 /*return*/];
            });
        }); };
        (_a = this._signal) === null || _a === void 0 ? void 0 : _a.on('signalingNotify', handleSignalEvent);
        // 在线多端同步通知
        this._signal.on('signalingMutilClientSyncNotify', function (event) { return __awaiter(_this, void 0, void 0, function () {
            var _a, _b;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0:
                        // 日志
                        (_a = this._logger) === null || _a === void 0 ? void 0 : _a.log(TAG_NAME, 'signalingMutilClientSyncNotify', event);
                        return [4 /*yield*/, this._batchMarkEvent([event])];
                    case 1:
                        _c.sent();
                        if (((_b = this._channelInfo) === null || _b === void 0 ? void 0 : _b.channelId) === event.channelId) {
                            switch (event.eventType) {
                                // 拒绝邀请
                                // 接收邀请
                                case 'ACCEPT':
                                    this.emit('whenSignalAcceptOtherClient');
                                    this.resetState();
                                    break;
                                case 'REJECT':
                                    this.emit('whenSignalRejectOtherClient');
                                    this.resetState();
                                    break;
                            }
                        }
                        return [2 /*return*/];
                }
            });
        }); });
        // 离线通知，调用signalingSync后触发
        this._signal.on('signalingUnreadMessageSyncNotify', function (data) { return __awaiter(_this, void 0, void 0, function () {
            var validMessages, validMessages_1, validMessages_1_1, validMessage, e_1_1;
            var e_1, _a;
            var _b;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0:
                        // 日志
                        (_b = this._logger) === null || _b === void 0 ? void 0 : _b.log(TAG_NAME, 'signalingUnreadMessageSyncNotify', data);
                        return [4 /*yield*/, this._batchMarkEvent(data)
                            // 过滤掉无效的离线消息
                        ];
                    case 1:
                        _c.sent();
                        validMessages = data.filter(function (item) { return !item.channelInValid; });
                        _c.label = 2;
                    case 2:
                        _c.trys.push([2, 7, 8, 9]);
                        validMessages_1 = __values(validMessages), validMessages_1_1 = validMessages_1.next();
                        _c.label = 3;
                    case 3:
                        if (!!validMessages_1_1.done) return [3 /*break*/, 6];
                        validMessage = validMessages_1_1.value;
                        return [4 /*yield*/, handleSignalEvent(validMessage)];
                    case 4:
                        _c.sent();
                        _c.label = 5;
                    case 5:
                        validMessages_1_1 = validMessages_1.next();
                        return [3 /*break*/, 3];
                    case 6: return [3 /*break*/, 9];
                    case 7:
                        e_1_1 = _c.sent();
                        e_1 = { error: e_1_1 };
                        return [3 /*break*/, 9];
                    case 8:
                        try {
                            if (validMessages_1_1 && !validMessages_1_1.done && (_a = validMessages_1.return)) _a.call(validMessages_1);
                        }
                        finally { if (e_1) throw e_1.error; }
                        return [7 /*endfinally*/];
                    case 9: return [2 /*return*/];
                }
            });
        }); });
    };
    SignalController.prototype._inviteHandler = function (event) {
        var _a;
        return __awaiter(this, void 0, void 0, function () {
            var channelId, requestId, account, attachExt, _b, _c;
            var _this = this;
            return __generator(this, function (_d) {
                switch (_d.label) {
                    case 0:
                        if (event.channelInValid) {
                            return [2 /*return*/];
                        }
                        channelId = event.channelId;
                        requestId = event.requestId;
                        account = event.from;
                        try {
                            attachExt = JSON.parse(event.attachExt);
                        }
                        catch (error) {
                            // 日志
                            (_a = this._logger) === null || _a === void 0 ? void 0 : _a.error(TAG_NAME, 'inviteHandler parse attachExt fail', error);
                            throw error;
                        }
                        if (!(this.callStatus !== SignalControllerCallingStatus.idle)) return [3 /*break*/, 2];
                        attachExt.reason = 3;
                        return [4 /*yield*/, this._signalReject({
                                channelId: channelId,
                                requestId: requestId,
                                account: account,
                                attachExt: attachExt,
                            })];
                    case 1:
                        _d.sent();
                        return [2 /*return*/];
                    case 2:
                        if (!this._enableAutoJoinSignalChannel) return [3 /*break*/, 4];
                        _b = this;
                        return [4 /*yield*/, this._signal.signalingJoin({
                                channelId: event.channelId,
                                // uid: this._uid,
                                // nertcChannelName: attachExt.channelName,
                                nertcTokenTtl: attachExt.rtcTokenTtl,
                                offlineEnabled: this._offlineEnabled,
                                attachExt: event.attachExt,
                            })];
                    case 3:
                        _b._channelInfo = (_d.sent());
                        return [3 /*break*/, 6];
                    case 4:
                        _c = this;
                        return [4 /*yield*/, this._signal.signalingGetChannelInfo({
                                channelName: event.channelName,
                            })];
                    case 5:
                        _c._channelInfo = (_d.sent());
                        _d.label = 6;
                    case 6:
                        this._channelInfo.callerId = account;
                        this._channelInfo.requestId = requestId;
                        this._channelInfo.attachExt = attachExt;
                        this.callStatus = SignalControllerCallingStatus.called;
                        this.emit('whenSignalInvite', this._channelInfo);
                        if (this.rejectTimeout) {
                            this._rejectTimer = setTimeout(function () { return __awaiter(_this, void 0, void 0, function () {
                                var error_9;
                                var _a, _b;
                                return __generator(this, function (_c) {
                                    switch (_c.label) {
                                        case 0:
                                            if (!(this.callStatus === SignalControllerCallingStatus.called)) return [3 /*break*/, 4];
                                            attachExt.reason = 2;
                                            _c.label = 1;
                                        case 1:
                                            _c.trys.push([1, 3, , 4]);
                                            return [4 /*yield*/, this._signalReject({
                                                    channelId: channelId,
                                                    requestId: requestId,
                                                    account: account,
                                                    attachExt: attachExt,
                                                })];
                                        case 2:
                                            _c.sent();
                                            (_a = this._logger) === null || _a === void 0 ? void 0 : _a.log(TAG_NAME, 'inviteHandler reject timeout cancel success', this.rejectTimeout);
                                            return [3 /*break*/, 4];
                                        case 3:
                                            error_9 = _c.sent();
                                            (_b = this._logger) === null || _b === void 0 ? void 0 : _b.error(TAG_NAME, 'inviteHandler reject timeout cancel fail: ', error_9, this.rejectTimeout);
                                            return [3 /*break*/, 4];
                                        case 4: return [2 /*return*/];
                                    }
                                });
                            }); }, this.rejectTimeout);
                        }
                        return [2 /*return*/];
                }
            });
        });
    };
    SignalController.prototype._signalRoomJoinHandler = function (event) {
        var _a;
        return __awaiter(this, void 0, void 0, function () {
            var channelInfo;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0: return [4 /*yield*/, this._signal.signalingGetChannelInfo({
                            channelName: (_a = this._channelInfo) === null || _a === void 0 ? void 0 : _a.channelName,
                        })];
                    case 1:
                        channelInfo = (_b.sent());
                        this._channelInfo = __assign(__assign({}, this._channelInfo), channelInfo);
                        this.emit('whenSignalRoomJoin', this._channelInfo);
                        return [2 /*return*/];
                }
            });
        });
    };
    SignalController.prototype._roomCloseHandler = function (event) {
        var _a;
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_b) {
                // 如果是channelId不对应，则不处理
                if (event.channelId !== ((_a = this._channelInfo) === null || _a === void 0 ? void 0 : _a.channelId)) {
                    return [2 /*return*/];
                }
                this.emit('whenSignalRoomClose');
                this.resetState();
                return [2 /*return*/];
            });
        });
    };
    SignalController.prototype._cancelInviteHandler = function (event) {
        var _a;
        return __awaiter(this, void 0, void 0, function () {
            var attachExt;
            return __generator(this, function (_b) {
                try {
                    attachExt = JSON.parse(event.attachExt);
                }
                catch (error) {
                    (_a = this._logger) === null || _a === void 0 ? void 0 : _a.error(TAG_NAME, 'inviteHandler:', 'parse attachExt error:', error);
                    throw error;
                }
                this.emit('whenSignalCancel', attachExt);
                this.resetState();
                return [2 /*return*/];
            });
        });
    };
    SignalController.prototype._rejectHandler = function (event) {
        var _a, _b;
        return __awaiter(this, void 0, void 0, function () {
            var from, calleeId, attachExt, reason;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0:
                        from = event.from;
                        calleeId = (_a = this._channelInfo) === null || _a === void 0 ? void 0 : _a.calleeId;
                        if (!(calleeId === from)) return [3 /*break*/, 5];
                        attachExt = void 0;
                        try {
                            attachExt = JSON.parse(event.attachExt);
                        }
                        catch (error) {
                            (_b = this._logger) === null || _b === void 0 ? void 0 : _b.error(TAG_NAME, 'inviteHandler:', 'parse attachExt error:', error);
                            throw error;
                        }
                        reason = attachExt.reason;
                        if (!(reason === 3)) return [3 /*break*/, 2];
                        return [4 /*yield*/, this._sendMessage(calleeId, 'busy')];
                    case 1:
                        _c.sent();
                        return [3 /*break*/, 4];
                    case 2: return [4 /*yield*/, this._sendMessage(calleeId, 'rejected')];
                    case 3:
                        _c.sent();
                        _c.label = 4;
                    case 4:
                        this.emit('whenSignalReject', attachExt);
                        this._signalClose();
                        _c.label = 5;
                    case 5: return [2 /*return*/];
                }
            });
        });
    };
    SignalController.prototype._acceptHandler = function (event) {
        var _a, _b, _c;
        return __awaiter(this, void 0, void 0, function () {
            var channelInfo, error_10;
            return __generator(this, function (_d) {
                switch (_d.label) {
                    case 0:
                        this.callStatus = SignalControllerCallingStatus.inCall;
                        this._callTimer && clearTimeout(this._callTimer);
                        _d.label = 1;
                    case 1:
                        _d.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, this._signal.signalingGetChannelInfo({
                                channelName: (_a = this._channelInfo) === null || _a === void 0 ? void 0 : _a.channelName,
                            })];
                    case 2:
                        channelInfo = (_d.sent());
                        this._channelInfo = __assign(__assign({}, this._channelInfo), channelInfo);
                        (_b = this._logger) === null || _b === void 0 ? void 0 : _b.log(TAG_NAME, 'acceptHandler from signal success:', event);
                        this.emit('whenSignalAccept', this._channelInfo);
                        return [3 /*break*/, 4];
                    case 3:
                        error_10 = _d.sent();
                        (_c = this._logger) === null || _c === void 0 ? void 0 : _c.error(TAG_NAME, 'acceptHandler error:', error_10);
                        throw error_10;
                    case 4: return [2 /*return*/];
                }
            });
        });
    };
    SignalController.prototype._controlHandler = function (event) {
        var _a, _b, _c;
        return __awaiter(this, void 0, void 0, function () {
            var attachExt;
            return __generator(this, function (_d) {
                try {
                    attachExt = void 0;
                    try {
                        attachExt = JSON.parse(event.attachExt);
                    }
                    catch (error) {
                        (_a = this._logger) === null || _a === void 0 ? void 0 : _a.error(TAG_NAME, 'inviteHandler:', 'parse attachExt error:', error);
                        throw error;
                    }
                    (_b = this._logger) === null || _b === void 0 ? void 0 : _b.log(TAG_NAME, 'controlHandler from signal success:', event);
                    this.emit('whenSignalControl', attachExt);
                }
                catch (error) {
                    (_c = this._logger) === null || _c === void 0 ? void 0 : _c.error(TAG_NAME, 'controlHandler error:', error);
                    throw error;
                }
                return [2 /*return*/];
            });
        });
    };
    /**
     * 接收呼叫
     */
    SignalController.prototype._signalAccept = function (params) {
        var _a, _b;
        return __awaiter(this, void 0, void 0, function () {
            var channelId, requestId, account, attachExt, channelInfo, error_11;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0:
                        _c.trys.push([0, 5, , 6]);
                        // 埋点
                        this.costTime.accept = Date.now();
                        // 日志
                        (_a = this._logger) === null || _a === void 0 ? void 0 : _a.log(TAG_NAME, '_signalAccept:', this._enableAutoJoinSignalChannel, this._channelInfo, params === null || params === void 0 ? void 0 : params.nertcJoinRoomQueryParamMap);
                        channelId = params.channelId, requestId = params.requestId, account = params.account, attachExt = params.attachExt;
                        if (!!this._enableAutoJoinSignalChannel) return [3 /*break*/, 2];
                        return [4 /*yield*/, this._signal.signalingJoinAndAccept({
                                channelId: channelId,
                                requestId: requestId,
                                account: account,
                                offlineEnabled: this._offlineEnabled,
                                attachExt: JSON.stringify(attachExt),
                                uid: this._uid,
                                nertcChannelName: attachExt.channelName,
                                nertcTokenTtl: attachExt.rtcTokenTtl,
                                nertcJoinRoomQueryParamMap: params === null || params === void 0 ? void 0 : params.nertcJoinRoomQueryParamMap,
                            })];
                    case 1:
                        channelInfo = (_c.sent());
                        channelInfo.members = formatMembers(channelInfo.members);
                        this._channelInfo = __assign(__assign({}, this._channelInfo), channelInfo);
                        return [3 /*break*/, 4];
                    case 2: return [4 /*yield*/, this._signal.signalingAccept({
                            channelId: channelId,
                            requestId: requestId,
                            account: account,
                            offlineEnabled: this._offlineEnabled,
                            attachExt: JSON.stringify(attachExt),
                        })];
                    case 3:
                        _c.sent();
                        _c.label = 4;
                    case 4:
                        // 埋点
                        this.costTime.accept = Date.now() - this.costTime.accept;
                        this.callStatus = SignalControllerCallingStatus.inCall;
                        this._channelInfo && this.emit('afterSignalAccept', this._channelInfo);
                        this._rejectTimer && clearTimeout(this._rejectTimer);
                        return [3 /*break*/, 6];
                    case 5:
                        error_11 = _c.sent();
                        // 这里不做处理，由 rejectTimer 事件处理
                        // this._signalClose()
                        (_b = this._logger) === null || _b === void 0 ? void 0 : _b.error(TAG_NAME, 'acceptSignal fail:', error_11);
                        throw error_11;
                    case 6: return [2 /*return*/];
                }
            });
        });
    };
    /**
     * 取消呼叫中的信令
     */
    SignalController.prototype._signalCancel = function (params) {
        var _a, _b;
        return __awaiter(this, void 0, void 0, function () {
            var channelId, requestId, account, attachExt, reason, error_12;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0:
                        channelId = params.channelId, requestId = params.requestId, account = params.account, attachExt = params.attachExt;
                        reason = attachExt.reason;
                        _c.label = 1;
                    case 1:
                        _c.trys.push([1, 3, 4, 5]);
                        return [4 /*yield*/, this._signal.signalingCancel({
                                channelId: channelId,
                                requestId: requestId,
                                account: account,
                                offlineEnabled: this._offlineEnabled,
                                attachExt: JSON.stringify(attachExt),
                            })];
                    case 2:
                        _c.sent();
                        if (reason === 2) {
                            this._sendMessage(account, 'timeout');
                        }
                        else {
                            this._sendMessage(account, 'canceled');
                        }
                        (_a = this._logger) === null || _a === void 0 ? void 0 : _a.log(TAG_NAME, 'signalCancel success');
                        return [3 /*break*/, 5];
                    case 3:
                        error_12 = _c.sent();
                        (_b = this._logger) === null || _b === void 0 ? void 0 : _b.error(TAG_NAME, 'signalCancel failed:', error_12);
                        throw error_12;
                    case 4:
                        this.emit('afterSignalCancel', { reason: reason });
                        this._signalClose();
                        this._callTimer && clearTimeout(this._callTimer);
                        return [7 /*endfinally*/];
                    case 5: return [2 /*return*/];
                }
            });
        });
    };
    /**
     * 拒绝通话，可能通过占线、超时、主动等方式触发
     */
    SignalController.prototype._signalReject = function (opt) {
        var _a, _b;
        return __awaiter(this, void 0, void 0, function () {
            var reason, error_13;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0:
                        reason = opt.attachExt.reason;
                        _c.label = 1;
                    case 1:
                        _c.trys.push([1, 3, 4, 5]);
                        return [4 /*yield*/, this._signal.signalingReject(__assign(__assign({}, opt), { attachExt: JSON.stringify(opt.attachExt), offlineEnabled: this._offlineEnabled }))];
                    case 2:
                        _c.sent();
                        (_a = this._logger) === null || _a === void 0 ? void 0 : _a.log(TAG_NAME, 'rejectReject success');
                        return [3 /*break*/, 5];
                    case 3:
                        error_13 = _c.sent();
                        (_b = this._logger) === null || _b === void 0 ? void 0 : _b.error(TAG_NAME, 'rejectReject failed:', error_13);
                        throw error_13;
                    case 4:
                        if (reason !== 3) {
                            this.emit('afterSignalReject', { reason: reason });
                            this.resetState();
                        }
                        return [7 /*endfinally*/];
                    case 5: return [2 /*return*/];
                }
            });
        });
    };
    /**
     * 关闭信令房间
     */
    SignalController.prototype._signalClose = function () {
        var _a, _b, _c, _d;
        return __awaiter(this, void 0, void 0, function () {
            var channelId, attachExt, error_14;
            return __generator(this, function (_e) {
                switch (_e.label) {
                    case 0:
                        _e.trys.push([0, 2, 3, 4]);
                        channelId = (_a = this._channelInfo) === null || _a === void 0 ? void 0 : _a.channelId;
                        attachExt = (_b = this._channelInfo) === null || _b === void 0 ? void 0 : _b.attachExt;
                        return [4 /*yield*/, this._signal.signalingClose({
                                channelId: channelId,
                                offlineEnabled: this._offlineEnabled,
                                attachExt: JSON.stringify(attachExt),
                            })];
                    case 1:
                        _e.sent();
                        (_c = this._logger) === null || _c === void 0 ? void 0 : _c.log('signalClose success');
                        return [3 /*break*/, 4];
                    case 2:
                        error_14 = _e.sent();
                        // 这里忽略关闭房间的错误
                        (_d = this._logger) === null || _d === void 0 ? void 0 : _d.warn(TAG_NAME, 'signalClose fail but resolve:', this._channelInfo, error_14);
                        return [3 /*break*/, 4];
                    case 3:
                        this.resetState();
                        return [7 /*endfinally*/];
                    case 4: return [2 /*return*/];
                }
            });
        });
    };
    /**
     * 批量标记消息已读
     * @param events
     */
    SignalController.prototype._batchMarkEvent = function (events) {
        var _a, _b;
        return __awaiter(this, void 0, void 0, function () {
            var msgids, e_2;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0:
                        _c.trys.push([0, 2, , 3]);
                        msgids = events.map(function (item) { return item.msgid + ''; });
                        return [4 /*yield*/, this._signal.signalingMarkMsgRead({
                                msgid: msgids,
                            })];
                    case 1:
                        _c.sent();
                        (_a = this._logger) === null || _a === void 0 ? void 0 : _a.log(TAG_NAME, '在线 signalingMarkMsgRead success');
                        return [3 /*break*/, 3];
                    case 2:
                        e_2 = _c.sent();
                        (_b = this._logger) === null || _b === void 0 ? void 0 : _b.warn(TAG_NAME, '在线 signalingMarkMsgRead fail: ', e_2);
                        return [3 /*break*/, 3];
                    case 3: return [2 /*return*/];
                }
            });
        });
    };
    /**
     * 单人通话下，需要通知服务端退出的情况
     * @param userId IM的account账号
     * @param status
     */
    SignalController.prototype._sendMessage = function (userId, status) {
        var _a, _b;
        return __awaiter(this, void 0, void 0, function () {
            var statusMap, attach;
            var _this = this;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0:
                        statusMap = {
                            canceled: 2,
                            rejected: 3,
                            timeout: 4,
                            busy: 5,
                        };
                        attach = {
                            type: (_a = this._channelInfo) === null || _a === void 0 ? void 0 : _a.type,
                            channelId: (_b = this._channelInfo) === null || _b === void 0 ? void 0 : _b.channelId,
                            status: statusMap[status],
                            durations: [],
                        };
                        return [4 /*yield*/, new Promise(function (resolve, reject) {
                                _this._signal.sendG2Msg({
                                    attach: attach,
                                    scene: 'p2p',
                                    to: userId,
                                    done: function (error) {
                                        var _a, _b;
                                        if (error) {
                                            (_a = _this._logger) === null || _a === void 0 ? void 0 : _a.error(TAG_NAME, 'sendMessage fail:', attach, error);
                                            return reject(error);
                                        }
                                        (_b = _this._logger) === null || _b === void 0 ? void 0 : _b.log(TAG_NAME, 'sendMessage success', attach, userId);
                                        _this.emit('afterMessageSend', {
                                            account: userId,
                                            attach: attach,
                                        });
                                        resolve();
                                    },
                                });
                            })];
                    case 1: return [2 /*return*/, _c.sent()];
                }
            });
        });
    };
    return SignalController;
}(eventemitter3));

var NERTC_Miniapp_SDK_v4_6_10 = createCommonjsModule(function (module) {
module.exports=function(e){var t={};function n(r){if(t[r])return t[r].exports;var i=t[r]={i:r,l:!1,exports:{}};return e[r].call(i.exports,i,i.exports,n),i.l=!0,i.exports}return n.m=e,n.c=t,n.d=function(e,t,r){n.o(e,t)||Object.defineProperty(e,t,{enumerable:!0,get:r});},n.r=function(e){"undefined"!=typeof Symbol&&Symbol.toStringTag&&Object.defineProperty(e,Symbol.toStringTag,{value:"Module"}),Object.defineProperty(e,"__esModule",{value:!0});},n.t=function(e,t){if(1&t&&(e=n(e)),8&t)return e;if(4&t&&"object"==typeof e&&e&&e.__esModule)return e;var r=Object.create(null);if(n.r(r),Object.defineProperty(r,"default",{enumerable:!0,value:e}),2&t&&"string"!=typeof e)for(var i in e)n.d(r,i,function(t){return e[t]}.bind(null,i));return r},n.n=function(e){var t=e&&e.__esModule?function(){return e.default}:function(){return e};return n.d(t,"a",t),t},n.o=function(e,t){return Object.prototype.hasOwnProperty.call(e,t)},n.p="",n(n.s=67)}([function(e,t){var n=e.exports="undefined"!=typeof window&&window.Math==Math?window:"undefined"!=typeof self&&self.Math==Math?self:Function("return this")();"number"==typeof __g&&(__g=n);},function(e,t,n){var r=n(36)("wks"),i=n(24),o=n(0).Symbol,s="function"==typeof o;(e.exports=function(e){return r[e]||(r[e]=s&&o[e]||(s?o:i)("Symbol."+e))}).store=r;},function(e,t){var n=e.exports={version:"2.6.9"};"number"==typeof __e&&(__e=n);},function(e,t,n){var r=n(8);e.exports=function(e){if(!r(e))throw TypeError(e+" is not an object!");return e};},function(e,t,n){t.__esModule=!0,t.default=function(e,t){if(!(e instanceof t))throw new TypeError("Cannot call a class as a function")};},function(e,t,n){t.__esModule=!0;var r,i=n(45),o=(r=i)&&r.__esModule?r:{default:r};t.default=function(){function e(e,t){for(var n=0;n<t.length;n++){var r=t[n];r.enumerable=r.enumerable||!1,r.configurable=!0,"value"in r&&(r.writable=!0),(0, o.default)(e,r.key,r);}}return function(t,n,r){return n&&e(t.prototype,n),r&&e(t,r),t}}();},function(e,t,n){var r=n(0),i=n(2),o=n(15),s=n(10),u=n(11),a=function(e,t,n){var c,l,f,d=e&a.F,p=e&a.G,h=e&a.S,g=e&a.P,_=e&a.B,m=e&a.W,v=p?i:i[t]||(i[t]={}),y=v.prototype,b=p?r:h?r[t]:(r[t]||{}).prototype;for(c in p&&(n=t),n)(l=!d&&b&&void 0!==b[c])&&u(v,c)||(f=l?b[c]:n[c],v[c]=p&&"function"!=typeof b[c]?n[c]:_&&l?o(f,r):m&&b[c]==f?function(e){var t=function(t,n,r){if(this instanceof e){switch(arguments.length){case 0:return new e;case 1:return new e(t);case 2:return new e(t,n)}return new e(t,n,r)}return e.apply(this,arguments)};return t.prototype=e.prototype,t}(f):g&&"function"==typeof f?o(Function.call,f):f,g&&((v.virtual||(v.virtual={}))[c]=f,e&a.R&&y&&!y[c]&&s(y,c,f)));};a.F=1,a.G=2,a.S=4,a.P=8,a.B=16,a.W=32,a.U=64,a.R=128,e.exports=a;},function(e,t,n){var r=n(3),i=n(46),o=n(30),s=Object.defineProperty;t.f=n(9)?Object.defineProperty:function(e,t,n){if(r(e),t=o(t,!0),r(n),i)try{return s(e,t,n)}catch(e){}if("get"in n||"set"in n)throw TypeError("Accessors not supported!");return "value"in n&&(e[t]=n.value),e};},function(e,t){e.exports=function(e){return "object"==typeof e?null!==e:"function"==typeof e};},function(e,t,n){e.exports=!n(22)(function(){return 7!=Object.defineProperty({},"a",{get:function(){return 7}}).a});},function(e,t,n){var r=n(7),i=n(23);e.exports=n(9)?function(e,t,n){return r.f(e,t,i(1,n))}:function(e,t,n){return e[t]=n,e};},function(e,t){var n={}.hasOwnProperty;e.exports=function(e,t){return n.call(e,t)};},function(e,t,n){t.__esModule=!0;var r=s(n(71)),i=s(n(83)),o="function"==typeof i.default&&"symbol"==typeof r.default?function(e){return typeof e}:function(e){return e&&"function"==typeof i.default&&e.constructor===i.default&&e!==i.default.prototype?"symbol":typeof e};function s(e){return e&&e.__esModule?e:{default:e}}t.default="function"==typeof i.default&&"symbol"===o(r.default)?function(e){return void 0===e?"undefined":o(e)}:function(e){return e&&"function"==typeof i.default&&e.constructor===i.default&&e!==i.default.prototype?"symbol":void 0===e?"undefined":o(e)};},function(e,t,n){var r=n(76),i=n(32);e.exports=function(e){return r(i(e))};},function(e,t,n){Object.defineProperty(t,"__esModule",{value:!0});var r=n(127);Object.defineProperty(t,"CONSTANT_ERROR",{enumerable:!0,get:function(){return o(r).default}});var i=n(128);function o(e){return e&&e.__esModule?e:{default:e}}Object.defineProperty(t,"CONSTANT_SOCKET",{enumerable:!0,get:function(){return o(i).default}});t.NETCALL_MODE={NETCALL_MODE_AUDIO_VIDEO:0,NETCALL_MODE_ONLY_AUDIO:1,NETCALL_MODE_ONLY_VIDEO:2,NETCALL_MODE_NOAUDIO_NOVIDEO:3},t.SESSION_MODE={P2P:0,MEETING:1},t.ROLE_FOR_MEETING={ROLE_HOST:0,ROLE_AUDIENCE:1},t.RECORD_TYPE={RECORD_TYPE_MIX_SINGLE:"0",RECORD_TYPE_ONLY_MIX:"1",RECORD_TYPE_ONLY_SINGLE:"2"},t.RECORD_AUDIO={RECORD_AUDIO_OPEN:1,RECORD_AUDIO_CLOSE:0},t.RECORD_VIDEO={RECORD_VIDEO_OPEN:1,RECORD_VIDEO_CLOSE:0},t.RTMP_RECORD={RTMP_RECORD_OPEN:1,RTMP_RECORD_CLOSE:0},t.LIVE_ENABLE={LIVE_ENABLE_OPEN:1,LIVE_ENABLE_CLOSE:0},t.VOICE_BEAUTIFIER_TYPE={VOICE_BEAUTIFIER_OFF:0,VOICE_BEAUTIFIER_MUFFLED:1,VOICE_BEAUTIFIER_MELLOW:2,VOICE_BEAUTIFIER_CLEAR:3,VOICE_BEAUTIFIER_MAGNETIC:4,VOICE_BEAUTIFIER_RECORDINGSTUDIO:5,VOICE_BEAUTIFIER_NATURE:6,VOICE_BEAUTIFIER_KTV:7,VOICE_BEAUTIFIER_REMOTE:8,VOICE_BEAUTIFIER_CHURCH:9,VOICE_BEAUTIFIER_BEDROOM:10,VOICE_BEAUTIFIER_LIVE:11},t.VOICE_EFFECT_TYPE={AUDIO_EFFECT_OFF:0,VOICE_CHANGER_EFFECT_ROBOT:1,VOICE_CHANGER_EFFECT_GIANT:2,VOICE_CHANGER_EFFECT_HORROR:3,VOICE_CHANGER_EFFECT_MATURE:4,VOICE_CHANGER_EFFECT_MANTOWOMAN:5,VOICE_CHANGER_EFFECT_WOMANTOMAN:6,VOICE_CHANGER_EFFECT_MANTOLOLI:7,VOICE_CHANGER_EFFECT_WOMANTOLOLI:8},t.AUDIO_EQUALIZATION_BAND={AUDIO_EQUALIZATION_BAND_31:31,AUDIO_EQUALIZATION_BAND_62:62,AUDIO_EQUALIZATION_BAND_125:125,AUDIO_EQUALIZATION_BAND_250:250,AUDIO_EQUALIZATION_BAND_500:500,AUDIO_EQUALIZATION_BAND_1K:1e3,AUDIO_EQUALIZATION_BAND_2K:2e3,AUDIO_EQUALIZATION_BAND_4K:4e3,AUDIO_EQUALIZATION_BAND_8K:8e3,AUDIO_EQUALIZATION_BAND_16K:16e3};},function(e,t,n){var r=n(21);e.exports=function(e,t,n){if(r(e),void 0===t)return e;switch(n){case 1:return function(n){return e.call(t,n)};case 2:return function(n,r){return e.call(t,n,r)};case 3:return function(n,r,i){return e.call(t,n,r,i)}}return function(){return e.apply(t,arguments)}};},function(e,t,n){t.__esModule=!0;var r,i=n(12),o=(r=i)&&r.__esModule?r:{default:r};t.default=function(e,t){if(!e)throw new ReferenceError("this hasn't been initialised - super() hasn't been called");return !t||"object"!==(void 0===t?"undefined":(0, o.default)(t))&&"function"!=typeof t?e:t};},function(e,t){e.exports=!0;},function(e,t){e.exports={};},function(e,t){var n={}.toString;e.exports=function(e){return n.call(e).slice(8,-1)};},function(e,t,n){t.__esModule=!0;var r=s(n(92)),i=s(n(96)),o=s(n(12));function s(e){return e&&e.__esModule?e:{default:e}}t.default=function(e,t){if("function"!=typeof t&&null!==t)throw new TypeError("Super expression must either be null or a function, not "+(void 0===t?"undefined":(0, o.default)(t)));e.prototype=(0, i.default)(t&&t.prototype,{constructor:{value:e,enumerable:!1,writable:!0,configurable:!0}}),t&&(r.default?(0, r.default)(e,t):e.__proto__=t);};},function(e,t){e.exports=function(e){if("function"!=typeof e)throw TypeError(e+" is not a function!");return e};},function(e,t){e.exports=function(e){try{return !!e()}catch(e){return !0}};},function(e,t){e.exports=function(e,t){return {enumerable:!(1&e),configurable:!(2&e),writable:!(4&e),value:t}};},function(e,t){var n=0,r=Math.random();e.exports=function(e){return "Symbol(".concat(void 0===e?"":e,")_",(++n+r).toString(36))};},function(e,t,n){var r=n(7).f,i=n(11),o=n(1)("toStringTag");e.exports=function(e,t,n){e&&!i(e=n?e:e.prototype,o)&&r(e,o,{configurable:!0,value:t});};},function(e,t,n){Object.defineProperty(t,"__esModule",{value:!0});var r=o(n(4)),i=o(n(5));function o(e){return e&&e.__esModule?e:{default:e}}var s=function(){function e(){(0, r.default)(this,e),this.eventReset();}return (0, i.default)(e,[{key:"eventReset",value:function(){var e=this;this._eventListeners&&Object.keys(this._eventListeners).forEach(function(t){delete e._eventListeners[t];}),this._eventListeners={},this._eventOnceListener&&Object.keys(this._eventOnceListener).forEach(function(t){delete e._eventOnceListener[t];}),this._eventOnceListener={};}},{key:"on",value:function(e,t){if(!e)throw Error({message:"event listener funkey undefined",callFunc:"adapter:_on"});if(!(t instanceof Function))throw Error({message:"event listener next param should be function",callFunc:"adapter:_on"});this._eventListeners[e]=t;}},{key:"off",value:function(e){if(!e)throw Error({message:"event listener funkey undefined",callFunc:"adapter:_off"});if(!this._eventListeners[e])throw Error({message:"event listener unbind failed!",callFunc:"adapter:_off"});delete this._eventListeners[e];}},{key:"once",value:function(e,t){if(!e)throw Error({message:"event once listener funkey undefined",callFunc:"adapter:_once"});if(!(t instanceof Function))throw Error({message:"event once listener next param should be function",callFunc:"adapter:_once"});this._eventOnceListener[e]=t;}},{key:"emit",value:function(e,t){var n=this;this._eventOnceListener&&this._eventOnceListener[e]instanceof Function&&setTimeout(function(){n._eventOnceListener[e](t),delete n._eventOnceListener[e];},0),this._eventListeners&&this._eventListeners[e]instanceof Function&&setTimeout(function(){n._eventListeners[e]&&n._eventListeners[e](t);},0);}}]),e}();t.default=s,e.exports=t.default;},function(e,t,n){Object.defineProperty(t,"__esModule",{value:!0});var r,i=n(12),o=(r=i)&&r.__esModule?r:{default:r};var s,u={post:function(e,t){var n=arguments.length>2&&void 0!==arguments[2]?arguments[2]:{};return this.verifyOptions(t,"url"),new Promise(function(r,i){"qq"===t.runtimeEnvironment?qq.request({url:t.url,method:"post",data:e,header:Object.assign({"content-type":"application/x-www-form-urlencoded"},n),success:function(e){var t=e.data;r(t);},fail:function(e){i(e);}}):wx.request({url:t.url,method:"post",data:e,header:Object.assign({"content-type":"application/x-www-form-urlencoded"},n),success:function(e){var t=e.data;r(t);},fail:function(e){i(e);}});})},merge:function(){var e=arguments;return e[0]=Object.assign.apply(Object.assign,arguments),e[0]},verifyOptions:function(){var e=arguments;if(e[0]&&e[0].constructor===Object)for(var t=1;t<arguments.length;t++){var n=e[t];(n=n.split(" ")).map(function(t){if(!e[0][t]&&0!=e[0][t])throw Error("参数缺失 "+t)});}},deepClone:function(e){var t=arguments.length>1&&void 0!==arguments[1]?arguments[1]:{};for(var n in e)"object"===(0, o.default)(e[n])?(t[n]=e[n].constructor===Array?[]:{},this.deepClone(e[n],t[n])):t[n]=e[n];return t},guid:(s=function(){return (65536*(1+Math.random())|0).toString(16).substring(1)},function(){return s()+s()+s()+s()+s()+s()+s()+s()}),uuid:function(){var e=function(){return (1e5*(1+Math.random())|0).toString(10).substring(1)};return function(){return e()+e()+e()}}(),isString:function(e){return e.constructor===String},isNumber:function(e){return e.constructor===Number},isBoolean:function(e){return e.constructor===Boolean},isObject:function(e){return e.constructor===Object},isArray:function(e){return e.constructor===Array},isFunction:function(e){return e.constructor===Function},isDate:function(e){return e.constructor===Date},isRegExp:function(e){return e.constructor===RegExp},isNull:function(e){return null===e},isUndefined:function(e){return void 0===e},exist:function(e){return !isNull(e)&&!isUndefined(e)}};t.default=u,e.exports=t.default;},function(e,t,n){var r;!function(i){var o,s=/^-?(?:\d+(?:\.\d*)?|\.\d+)(?:e[+-]?\d+)?$/i,u=Math.ceil,a=Math.floor,c="[BigNumber Error] ",l=c+"Number primitive has more than 15 significant digits: ",f=1e14,d=14,p=9007199254740991,h=[1,10,100,1e3,1e4,1e5,1e6,1e7,1e8,1e9,1e10,1e11,1e12,1e13],g=1e7,_=1e9;function m(e){var t=0|e;return e>0||e===t?t:t-1}function v(e){for(var t,n,r=1,i=e.length,o=e[0]+"";r<i;){for(t=e[r++]+"",n=d-t.length;n--;t="0"+t);o+=t;}for(i=o.length;48===o.charCodeAt(--i););return o.slice(0,i+1||1)}function y(e,t){var n,r,i=e.c,o=t.c,s=e.s,u=t.s,a=e.e,c=t.e;if(!s||!u)return null;if(n=i&&!i[0],r=o&&!o[0],n||r)return n?r?0:-u:s;if(s!=u)return s;if(n=s<0,r=a==c,!i||!o)return r?0:!i^n?1:-1;if(!r)return a>c^n?1:-1;for(u=(a=i.length)<(c=o.length)?a:c,s=0;s<u;s++)if(i[s]!=o[s])return i[s]>o[s]^n?1:-1;return a==c?0:a>c^n?1:-1}function b(e,t,n,r){if(e<t||e>n||e!==a(e))throw Error(c+(r||"Argument")+("number"==typeof e?e<t||e>n?" out of range: ":" not an integer: ":" not a primitive number: ")+String(e))}function E(e){var t=e.c.length-1;return m(e.e/d)==t&&e.c[t]%2!=0}function O(e,t){return (e.length>1?e.charAt(0)+"."+e.slice(1):e)+(t<0?"e":"e+")+t}function T(e,t,n){var r,i;if(t<0){for(i=n+".";++t;i+=n);e=i+e;}else if(++t>(r=e.length)){for(i=n,t-=r;--t;i+=n);e+=i;}else t<r&&(e=e.slice(0,t)+"."+e.slice(t));return e}(o=function e(t){var n,r,i,o,k,A,N,I,C,w=G.prototype={constructor:G,toString:null,valueOf:null},S=new G(1),R=20,x=4,L=-7,P=21,F=-1e7,U=1e7,D=!1,j=1,B=0,M={prefix:"",groupSize:3,secondaryGroupSize:0,groupSeparator:",",decimalSeparator:".",fractionGroupSize:0,fractionGroupSeparator:" ",suffix:""},V="0123456789abcdefghijklmnopqrstuvwxyz";function G(e,t){var n,o,u,c,f,h,g,_,m=this;if(!(m instanceof G))return new G(e,t);if(null==t){if(e&&!0===e._isBigNumber)return m.s=e.s,void(!e.c||e.e>U?m.c=m.e=null:e.e<F?m.c=[m.e=0]:(m.e=e.e,m.c=e.c.slice()));if((h="number"==typeof e)&&0*e==0){if(m.s=1/e<0?(e=-e,-1):1,e===~~e){for(c=0,f=e;f>=10;f/=10,c++);return void(c>U?m.c=m.e=null:(m.e=c,m.c=[e]))}_=String(e);}else {if(!s.test(_=String(e)))return i(m,_,h);m.s=45==_.charCodeAt(0)?(_=_.slice(1),-1):1;}(c=_.indexOf("."))>-1&&(_=_.replace(".","")),(f=_.search(/e/i))>0?(c<0&&(c=f),c+=+_.slice(f+1),_=_.substring(0,f)):c<0&&(c=_.length);}else {if(b(t,2,V.length,"Base"),10==t)return Q(m=new G(e),R+m.e+1,x);if(_=String(e),h="number"==typeof e){if(0*e!=0)return i(m,_,h,t);if(m.s=1/e<0?(_=_.slice(1),-1):1,G.DEBUG&&_.replace(/^0\.0*|\./,"").length>15)throw Error(l+e)}else m.s=45===_.charCodeAt(0)?(_=_.slice(1),-1):1;for(n=V.slice(0,t),c=f=0,g=_.length;f<g;f++)if(n.indexOf(o=_.charAt(f))<0){if("."==o){if(f>c){c=g;continue}}else if(!u&&(_==_.toUpperCase()&&(_=_.toLowerCase())||_==_.toLowerCase()&&(_=_.toUpperCase()))){u=!0,f=-1,c=0;continue}return i(m,String(e),h,t)}h=!1,(c=(_=r(_,t,10,m.s)).indexOf("."))>-1?_=_.replace(".",""):c=_.length;}for(f=0;48===_.charCodeAt(f);f++);for(g=_.length;48===_.charCodeAt(--g););if(_=_.slice(f,++g)){if(g-=f,h&&G.DEBUG&&g>15&&(e>p||e!==a(e)))throw Error(l+m.s*e);if((c=c-f-1)>U)m.c=m.e=null;else if(c<F)m.c=[m.e=0];else {if(m.e=c,m.c=[],f=(c+1)%d,c<0&&(f+=d),f<g){for(f&&m.c.push(+_.slice(0,f)),g-=d;f<g;)m.c.push(+_.slice(f,f+=d));f=d-(_=_.slice(f)).length;}else f-=g;for(;f--;_+="0");m.c.push(+_);}}else m.c=[m.e=0];}function H(e,t,n,r){var i,o,s,u,a;if(null==n?n=x:b(n,0,8),!e.c)return e.toString();if(i=e.c[0],s=e.e,null==t)a=v(e.c),a=1==r||2==r&&(s<=L||s>=P)?O(a,s):T(a,s,"0");else if(o=(e=Q(new G(e),t,n)).e,u=(a=v(e.c)).length,1==r||2==r&&(t<=o||o<=L)){for(;u<t;a+="0",u++);a=O(a,o);}else if(t-=s,a=T(a,o,"0"),o+1>u){if(--t>0)for(a+=".";t--;a+="0");}else if((t+=o-u)>0)for(o+1==u&&(a+=".");t--;a+="0");return e.s<0&&i?"-"+a:a}function q(e,t){for(var n,r=1,i=new G(e[0]);r<e.length;r++){if(!(n=new G(e[r])).s){i=n;break}t.call(i,n)&&(i=n);}return i}function Z(e,t,n){for(var r=1,i=t.length;!t[--i];t.pop());for(i=t[0];i>=10;i/=10,r++);return (n=r+n*d-1)>U?e.c=e.e=null:n<F?e.c=[e.e=0]:(e.e=n,e.c=t),e}function Q(e,t,n,r){var i,o,s,c,l,p,g,_=e.c,m=h;if(_){e:{for(i=1,c=_[0];c>=10;c/=10,i++);if((o=t-i)<0)o+=d,s=t,g=(l=_[p=0])/m[i-s-1]%10|0;else if((p=u((o+1)/d))>=_.length){if(!r)break e;for(;_.length<=p;_.push(0));l=g=0,i=1,s=(o%=d)-d+1;}else {for(l=c=_[p],i=1;c>=10;c/=10,i++);g=(s=(o%=d)-d+i)<0?0:l/m[i-s-1]%10|0;}if(r=r||t<0||null!=_[p+1]||(s<0?l:l%m[i-s-1]),r=n<4?(g||r)&&(0==n||n==(e.s<0?3:2)):g>5||5==g&&(4==n||r||6==n&&(o>0?s>0?l/m[i-s]:0:_[p-1])%10&1||n==(e.s<0?8:7)),t<1||!_[0])return _.length=0,r?(t-=e.e+1,_[0]=m[(d-t%d)%d],e.e=-t||0):_[0]=e.e=0,e;if(0==o?(_.length=p,c=1,p--):(_.length=p+1,c=m[d-o],_[p]=s>0?a(l/m[i-s]%m[s])*c:0),r)for(;;){if(0==p){for(o=1,s=_[0];s>=10;s/=10,o++);for(s=_[0]+=c,c=1;s>=10;s/=10,c++);o!=c&&(e.e++,_[0]==f&&(_[0]=1));break}if(_[p]+=c,_[p]!=f)break;_[p--]=0,c=1;}for(o=_.length;0===_[--o];_.pop());}e.e>U?e.c=e.e=null:e.e<F&&(e.c=[e.e=0]);}return e}function J(e){var t,n=e.e;return null===n?e.toString():(t=v(e.c),t=n<=L||n>=P?O(t,n):T(t,n,"0"),e.s<0?"-"+t:t)}return G.clone=e,G.ROUND_UP=0,G.ROUND_DOWN=1,G.ROUND_CEIL=2,G.ROUND_FLOOR=3,G.ROUND_HALF_UP=4,G.ROUND_HALF_DOWN=5,G.ROUND_HALF_EVEN=6,G.ROUND_HALF_CEIL=7,G.ROUND_HALF_FLOOR=8,G.EUCLID=9,G.config=G.set=function(e){var t,n;if(null!=e){if("object"!=typeof e)throw Error(c+"Object expected: "+e);if(e.hasOwnProperty(t="DECIMAL_PLACES")&&(b(n=e[t],0,_,t),R=n),e.hasOwnProperty(t="ROUNDING_MODE")&&(b(n=e[t],0,8,t),x=n),e.hasOwnProperty(t="EXPONENTIAL_AT")&&((n=e[t])&&n.pop?(b(n[0],-_,0,t),b(n[1],0,_,t),L=n[0],P=n[1]):(b(n,-_,_,t),L=-(P=n<0?-n:n))),e.hasOwnProperty(t="RANGE"))if((n=e[t])&&n.pop)b(n[0],-_,-1,t),b(n[1],1,_,t),F=n[0],U=n[1];else {if(b(n,-_,_,t),!n)throw Error(c+t+" cannot be zero: "+n);F=-(U=n<0?-n:n);}if(e.hasOwnProperty(t="CRYPTO")){if((n=e[t])!==!!n)throw Error(c+t+" not true or false: "+n);if(n){if("undefined"==typeof crypto||!crypto||!crypto.getRandomValues&&!crypto.randomBytes)throw D=!n,Error(c+"crypto unavailable");D=n;}else D=n;}if(e.hasOwnProperty(t="MODULO_MODE")&&(b(n=e[t],0,9,t),j=n),e.hasOwnProperty(t="POW_PRECISION")&&(b(n=e[t],0,_,t),B=n),e.hasOwnProperty(t="FORMAT")){if("object"!=typeof(n=e[t]))throw Error(c+t+" not an object: "+n);M=n;}if(e.hasOwnProperty(t="ALPHABET")){if("string"!=typeof(n=e[t])||/^.?$|[+\-.\s]|(.).*\1/.test(n))throw Error(c+t+" invalid: "+n);V=n;}}return {DECIMAL_PLACES:R,ROUNDING_MODE:x,EXPONENTIAL_AT:[L,P],RANGE:[F,U],CRYPTO:D,MODULO_MODE:j,POW_PRECISION:B,FORMAT:M,ALPHABET:V}},G.isBigNumber=function(e){if(!e||!0!==e._isBigNumber)return !1;if(!G.DEBUG)return !0;var t,n,r=e.c,i=e.e,o=e.s;e:if("[object Array]"=={}.toString.call(r)){if((1===o||-1===o)&&i>=-_&&i<=_&&i===a(i)){if(0===r[0]){if(0===i&&1===r.length)return !0;break e}if((t=(i+1)%d)<1&&(t+=d),String(r[0]).length==t){for(t=0;t<r.length;t++)if((n=r[t])<0||n>=f||n!==a(n))break e;if(0!==n)return !0}}}else if(null===r&&null===i&&(null===o||1===o||-1===o))return !0;throw Error(c+"Invalid BigNumber: "+e)},G.maximum=G.max=function(){return q(arguments,w.lt)},G.minimum=G.min=function(){return q(arguments,w.gt)},G.random=(o=9007199254740992*Math.random()&2097151?function(){return a(9007199254740992*Math.random())}:function(){return 8388608*(1073741824*Math.random()|0)+(8388608*Math.random()|0)},function(e){var t,n,r,i,s,l=0,f=[],p=new G(S);if(null==e?e=R:b(e,0,_),i=u(e/d),D)if(crypto.getRandomValues){for(t=crypto.getRandomValues(new Uint32Array(i*=2));l<i;)(s=131072*t[l]+(t[l+1]>>>11))>=9e15?(n=crypto.getRandomValues(new Uint32Array(2)),t[l]=n[0],t[l+1]=n[1]):(f.push(s%1e14),l+=2);l=i/2;}else {if(!crypto.randomBytes)throw D=!1,Error(c+"crypto unavailable");for(t=crypto.randomBytes(i*=7);l<i;)(s=281474976710656*(31&t[l])+1099511627776*t[l+1]+4294967296*t[l+2]+16777216*t[l+3]+(t[l+4]<<16)+(t[l+5]<<8)+t[l+6])>=9e15?crypto.randomBytes(7).copy(t,l):(f.push(s%1e14),l+=7);l=i/7;}if(!D)for(;l<i;)(s=o())<9e15&&(f[l++]=s%1e14);for(i=f[--l],e%=d,i&&e&&(s=h[d-e],f[l]=a(i/s)*s);0===f[l];f.pop(),l--);if(l<0)f=[r=0];else {for(r=-1;0===f[0];f.splice(0,1),r-=d);for(l=1,s=f[0];s>=10;s/=10,l++);l<d&&(r-=d-l);}return p.e=r,p.c=f,p}),G.sum=function(){for(var e=1,t=arguments,n=new G(t[0]);e<t.length;)n=n.plus(t[e++]);return n},r=function(){function e(e,t,n,r){for(var i,o,s=[0],u=0,a=e.length;u<a;){for(o=s.length;o--;s[o]*=t);for(s[0]+=r.indexOf(e.charAt(u++)),i=0;i<s.length;i++)s[i]>n-1&&(null==s[i+1]&&(s[i+1]=0),s[i+1]+=s[i]/n|0,s[i]%=n);}return s.reverse()}return function(t,r,i,o,s){var u,a,c,l,f,d,p,h,g=t.indexOf("."),_=R,m=x;for(g>=0&&(l=B,B=0,t=t.replace(".",""),d=(h=new G(r)).pow(t.length-g),B=l,h.c=e(T(v(d.c),d.e,"0"),10,i,"0123456789"),h.e=h.c.length),c=l=(p=e(t,r,i,s?(u=V,"0123456789"):(u="0123456789",V))).length;0==p[--l];p.pop());if(!p[0])return u.charAt(0);if(g<0?--c:(d.c=p,d.e=c,d.s=o,p=(d=n(d,h,_,m,i)).c,f=d.r,c=d.e),g=p[a=c+_+1],l=i/2,f=f||a<0||null!=p[a+1],f=m<4?(null!=g||f)&&(0==m||m==(d.s<0?3:2)):g>l||g==l&&(4==m||f||6==m&&1&p[a-1]||m==(d.s<0?8:7)),a<1||!p[0])t=f?T(u.charAt(1),-_,u.charAt(0)):u.charAt(0);else {if(p.length=a,f)for(--i;++p[--a]>i;)p[a]=0,a||(++c,p=[1].concat(p));for(l=p.length;!p[--l];);for(g=0,t="";g<=l;t+=u.charAt(p[g++]));t=T(t,c,u.charAt(0));}return t}}(),n=function(){function e(e,t,n){var r,i,o,s,u=0,a=e.length,c=t%g,l=t/g|0;for(e=e.slice();a--;)u=((i=c*(o=e[a]%g)+(r=l*o+(s=e[a]/g|0)*c)%g*g+u)/n|0)+(r/g|0)+l*s,e[a]=i%n;return u&&(e=[u].concat(e)),e}function t(e,t,n,r){var i,o;if(n!=r)o=n>r?1:-1;else for(i=o=0;i<n;i++)if(e[i]!=t[i]){o=e[i]>t[i]?1:-1;break}return o}function n(e,t,n,r){for(var i=0;n--;)e[n]-=i,i=e[n]<t[n]?1:0,e[n]=i*r+e[n]-t[n];for(;!e[0]&&e.length>1;e.splice(0,1));}return function(r,i,o,s,u){var c,l,p,h,g,_,v,y,b,E,O,T,k,A,N,I,C,w=r.s==i.s?1:-1,S=r.c,R=i.c;if(!(S&&S[0]&&R&&R[0]))return new G(r.s&&i.s&&(S?!R||S[0]!=R[0]:R)?S&&0==S[0]||!R?0*w:w/0:NaN);for(b=(y=new G(w)).c=[],w=o+(l=r.e-i.e)+1,u||(u=f,l=m(r.e/d)-m(i.e/d),w=w/d|0),p=0;R[p]==(S[p]||0);p++);if(R[p]>(S[p]||0)&&l--,w<0)b.push(1),h=!0;else {for(A=S.length,I=R.length,p=0,w+=2,(g=a(u/(R[0]+1)))>1&&(R=e(R,g,u),S=e(S,g,u),I=R.length,A=S.length),k=I,O=(E=S.slice(0,I)).length;O<I;E[O++]=0);C=R.slice(),C=[0].concat(C),N=R[0],R[1]>=u/2&&N++;do{if(g=0,(c=t(R,E,I,O))<0){if(T=E[0],I!=O&&(T=T*u+(E[1]||0)),(g=a(T/N))>1)for(g>=u&&(g=u-1),v=(_=e(R,g,u)).length,O=E.length;1==t(_,E,v,O);)g--,n(_,I<v?C:R,v,u),v=_.length,c=1;else 0==g&&(c=g=1),v=(_=R.slice()).length;if(v<O&&(_=[0].concat(_)),n(E,_,O,u),O=E.length,-1==c)for(;t(R,E,I,O)<1;)g++,n(E,I<O?C:R,O,u),O=E.length;}else 0===c&&(g++,E=[0]);b[p++]=g,E[0]?E[O++]=S[k]||0:(E=[S[k]],O=1);}while((k++<A||null!=E[0])&&w--);h=null!=E[0],b[0]||b.splice(0,1);}if(u==f){for(p=1,w=b[0];w>=10;w/=10,p++);Q(y,o+(y.e=p+l*d-1)+1,s,h);}else y.e=l,y.r=+h;return y}}(),k=/^(-?)0([xbo])(?=\w[\w.]*$)/i,A=/^([^.]+)\.$/,N=/^\.([^.]+)$/,I=/^-?(Infinity|NaN)$/,C=/^\s*\+(?=[\w.])|^\s+|\s+$/g,i=function(e,t,n,r){var i,o=n?t:t.replace(C,"");if(I.test(o))e.s=isNaN(o)?null:o<0?-1:1;else {if(!n&&(o=o.replace(k,function(e,t,n){return i="x"==(n=n.toLowerCase())?16:"b"==n?2:8,r&&r!=i?e:t}),r&&(i=r,o=o.replace(A,"$1").replace(N,"0.$1")),t!=o))return new G(o,i);if(G.DEBUG)throw Error(c+"Not a"+(r?" base "+r:"")+" number: "+t);e.s=null;}e.c=e.e=null;},w.absoluteValue=w.abs=function(){var e=new G(this);return e.s<0&&(e.s=1),e},w.comparedTo=function(e,t){return y(this,new G(e,t))},w.decimalPlaces=w.dp=function(e,t){var n,r,i,o=this;if(null!=e)return b(e,0,_),null==t?t=x:b(t,0,8),Q(new G(o),e+o.e+1,t);if(!(n=o.c))return null;if(r=((i=n.length-1)-m(this.e/d))*d,i=n[i])for(;i%10==0;i/=10,r--);return r<0&&(r=0),r},w.dividedBy=w.div=function(e,t){return n(this,new G(e,t),R,x)},w.dividedToIntegerBy=w.idiv=function(e,t){return n(this,new G(e,t),0,1)},w.exponentiatedBy=w.pow=function(e,t){var n,r,i,o,s,l,f,p,h=this;if((e=new G(e)).c&&!e.isInteger())throw Error(c+"Exponent not an integer: "+J(e));if(null!=t&&(t=new G(t)),s=e.e>14,!h.c||!h.c[0]||1==h.c[0]&&!h.e&&1==h.c.length||!e.c||!e.c[0])return p=new G(Math.pow(+J(h),s?2-E(e):+J(e))),t?p.mod(t):p;if(l=e.s<0,t){if(t.c?!t.c[0]:!t.s)return new G(NaN);(r=!l&&h.isInteger()&&t.isInteger())&&(h=h.mod(t));}else {if(e.e>9&&(h.e>0||h.e<-1||(0==h.e?h.c[0]>1||s&&h.c[1]>=24e7:h.c[0]<8e13||s&&h.c[0]<=9999975e7)))return o=h.s<0&&E(e)?-0:0,h.e>-1&&(o=1/o),new G(l?1/o:o);B&&(o=u(B/d+2));}for(s?(n=new G(.5),l&&(e.s=1),f=E(e)):f=(i=Math.abs(+J(e)))%2,p=new G(S);;){if(f){if(!(p=p.times(h)).c)break;o?p.c.length>o&&(p.c.length=o):r&&(p=p.mod(t));}if(i){if(0===(i=a(i/2)))break;f=i%2;}else if(Q(e=e.times(n),e.e+1,1),e.e>14)f=E(e);else {if(0==(i=+J(e)))break;f=i%2;}h=h.times(h),o?h.c&&h.c.length>o&&(h.c.length=o):r&&(h=h.mod(t));}return r?p:(l&&(p=S.div(p)),t?p.mod(t):o?Q(p,B,x,void 0):p)},w.integerValue=function(e){var t=new G(this);return null==e?e=x:b(e,0,8),Q(t,t.e+1,e)},w.isEqualTo=w.eq=function(e,t){return 0===y(this,new G(e,t))},w.isFinite=function(){return !!this.c},w.isGreaterThan=w.gt=function(e,t){return y(this,new G(e,t))>0},w.isGreaterThanOrEqualTo=w.gte=function(e,t){return 1===(t=y(this,new G(e,t)))||0===t},w.isInteger=function(){return !!this.c&&m(this.e/d)>this.c.length-2},w.isLessThan=w.lt=function(e,t){return y(this,new G(e,t))<0},w.isLessThanOrEqualTo=w.lte=function(e,t){return -1===(t=y(this,new G(e,t)))||0===t},w.isNaN=function(){return !this.s},w.isNegative=function(){return this.s<0},w.isPositive=function(){return this.s>0},w.isZero=function(){return !!this.c&&0==this.c[0]},w.minus=function(e,t){var n,r,i,o,s=this,u=s.s;if(t=(e=new G(e,t)).s,!u||!t)return new G(NaN);if(u!=t)return e.s=-t,s.plus(e);var a=s.e/d,c=e.e/d,l=s.c,p=e.c;if(!a||!c){if(!l||!p)return l?(e.s=-t,e):new G(p?s:NaN);if(!l[0]||!p[0])return p[0]?(e.s=-t,e):new G(l[0]?s:3==x?-0:0)}if(a=m(a),c=m(c),l=l.slice(),u=a-c){for((o=u<0)?(u=-u,i=l):(c=a,i=p),i.reverse(),t=u;t--;i.push(0));i.reverse();}else for(r=(o=(u=l.length)<(t=p.length))?u:t,u=t=0;t<r;t++)if(l[t]!=p[t]){o=l[t]<p[t];break}if(o&&(i=l,l=p,p=i,e.s=-e.s),(t=(r=p.length)-(n=l.length))>0)for(;t--;l[n++]=0);for(t=f-1;r>u;){if(l[--r]<p[r]){for(n=r;n&&!l[--n];l[n]=t);--l[n],l[r]+=f;}l[r]-=p[r];}for(;0==l[0];l.splice(0,1),--c);return l[0]?Z(e,l,c):(e.s=3==x?-1:1,e.c=[e.e=0],e)},w.modulo=w.mod=function(e,t){var r,i,o=this;return e=new G(e,t),!o.c||!e.s||e.c&&!e.c[0]?new G(NaN):!e.c||o.c&&!o.c[0]?new G(o):(9==j?(i=e.s,e.s=1,r=n(o,e,0,3),e.s=i,r.s*=i):r=n(o,e,0,j),(e=o.minus(r.times(e))).c[0]||1!=j||(e.s=o.s),e)},w.multipliedBy=w.times=function(e,t){var n,r,i,o,s,u,a,c,l,p,h,_,v,y,b,E=this,O=E.c,T=(e=new G(e,t)).c;if(!(O&&T&&O[0]&&T[0]))return !E.s||!e.s||O&&!O[0]&&!T||T&&!T[0]&&!O?e.c=e.e=e.s=null:(e.s*=E.s,O&&T?(e.c=[0],e.e=0):e.c=e.e=null),e;for(r=m(E.e/d)+m(e.e/d),e.s*=E.s,(a=O.length)<(p=T.length)&&(v=O,O=T,T=v,i=a,a=p,p=i),i=a+p,v=[];i--;v.push(0));for(y=f,b=g,i=p;--i>=0;){for(n=0,h=T[i]%b,_=T[i]/b|0,o=i+(s=a);o>i;)n=((c=h*(c=O[--s]%b)+(u=_*c+(l=O[s]/b|0)*h)%b*b+v[o]+n)/y|0)+(u/b|0)+_*l,v[o--]=c%y;v[o]=n;}return n?++r:v.splice(0,1),Z(e,v,r)},w.negated=function(){var e=new G(this);return e.s=-e.s||null,e},w.plus=function(e,t){var n,r=this,i=r.s;if(t=(e=new G(e,t)).s,!i||!t)return new G(NaN);if(i!=t)return e.s=-t,r.minus(e);var o=r.e/d,s=e.e/d,u=r.c,a=e.c;if(!o||!s){if(!u||!a)return new G(i/0);if(!u[0]||!a[0])return a[0]?e:new G(u[0]?r:0*i)}if(o=m(o),s=m(s),u=u.slice(),i=o-s){for(i>0?(s=o,n=a):(i=-i,n=u),n.reverse();i--;n.push(0));n.reverse();}for((i=u.length)-(t=a.length)<0&&(n=a,a=u,u=n,t=i),i=0;t;)i=(u[--t]=u[t]+a[t]+i)/f|0,u[t]=f===u[t]?0:u[t]%f;return i&&(u=[i].concat(u),++s),Z(e,u,s)},w.precision=w.sd=function(e,t){var n,r,i,o=this;if(null!=e&&e!==!!e)return b(e,1,_),null==t?t=x:b(t,0,8),Q(new G(o),e,t);if(!(n=o.c))return null;if(r=(i=n.length-1)*d+1,i=n[i]){for(;i%10==0;i/=10,r--);for(i=n[0];i>=10;i/=10,r++);}return e&&o.e+1>r&&(r=o.e+1),r},w.shiftedBy=function(e){return b(e,-p,p),this.times("1e"+e)},w.squareRoot=w.sqrt=function(){var e,t,r,i,o,s=this,u=s.c,a=s.s,c=s.e,l=R+4,f=new G("0.5");if(1!==a||!u||!u[0])return new G(!a||a<0&&(!u||u[0])?NaN:u?s:1/0);if(0==(a=Math.sqrt(+J(s)))||a==1/0?(((t=v(u)).length+c)%2==0&&(t+="0"),a=Math.sqrt(+t),c=m((c+1)/2)-(c<0||c%2),r=new G(t=a==1/0?"5e"+c:(t=a.toExponential()).slice(0,t.indexOf("e")+1)+c)):r=new G(a+""),r.c[0])for((a=(c=r.e)+l)<3&&(a=0);;)if(o=r,r=f.times(o.plus(n(s,o,l,1))),v(o.c).slice(0,a)===(t=v(r.c)).slice(0,a)){if(r.e<c&&--a,"9999"!=(t=t.slice(a-3,a+1))&&(i||"4999"!=t)){+t&&(+t.slice(1)||"5"!=t.charAt(0))||(Q(r,r.e+R+2,1),e=!r.times(r).eq(s));break}if(!i&&(Q(o,o.e+R+2,0),o.times(o).eq(s))){r=o;break}l+=4,a+=4,i=1;}return Q(r,r.e+R+1,x,e)},w.toExponential=function(e,t){return null!=e&&(b(e,0,_),e++),H(this,e,t,1)},w.toFixed=function(e,t){return null!=e&&(b(e,0,_),e=e+this.e+1),H(this,e,t)},w.toFormat=function(e,t,n){var r,i=this;if(null==n)null!=e&&t&&"object"==typeof t?(n=t,t=null):e&&"object"==typeof e?(n=e,e=t=null):n=M;else if("object"!=typeof n)throw Error(c+"Argument not an object: "+n);if(r=i.toFixed(e,t),i.c){var o,s=r.split("."),u=+n.groupSize,a=+n.secondaryGroupSize,l=n.groupSeparator||"",f=s[0],d=s[1],p=i.s<0,h=p?f.slice(1):f,g=h.length;if(a&&(o=u,u=a,a=o,g-=o),u>0&&g>0){for(o=g%u||u,f=h.substr(0,o);o<g;o+=u)f+=l+h.substr(o,u);a>0&&(f+=l+h.slice(o)),p&&(f="-"+f);}r=d?f+(n.decimalSeparator||"")+((a=+n.fractionGroupSize)?d.replace(new RegExp("\\d{"+a+"}\\B","g"),"$&"+(n.fractionGroupSeparator||"")):d):f;}return (n.prefix||"")+r+(n.suffix||"")},w.toFraction=function(e){var t,r,i,o,s,u,a,l,f,p,g,_,m=this,y=m.c;if(null!=e&&(!(a=new G(e)).isInteger()&&(a.c||1!==a.s)||a.lt(S)))throw Error(c+"Argument "+(a.isInteger()?"out of range: ":"not an integer: ")+J(a));if(!y)return new G(m);for(t=new G(S),f=r=new G(S),i=l=new G(S),_=v(y),s=t.e=_.length-m.e-1,t.c[0]=h[(u=s%d)<0?d+u:u],e=!e||a.comparedTo(t)>0?s>0?t:f:a,u=U,U=1/0,a=new G(_),l.c[0]=0;p=n(a,t,0,1),1!=(o=r.plus(p.times(i))).comparedTo(e);)r=i,i=o,f=l.plus(p.times(o=f)),l=o,t=a.minus(p.times(o=t)),a=o;return o=n(e.minus(r),i,0,1),l=l.plus(o.times(f)),r=r.plus(o.times(i)),l.s=f.s=m.s,g=n(f,i,s*=2,x).minus(m).abs().comparedTo(n(l,r,s,x).minus(m).abs())<1?[f,i]:[l,r],U=u,g},w.toNumber=function(){return +J(this)},w.toPrecision=function(e,t){return null!=e&&b(e,1,_),H(this,e,t,2)},w.toString=function(e){var t,n=this,i=n.s,o=n.e;return null===o?i?(t="Infinity",i<0&&(t="-"+t)):t="NaN":(null==e?t=o<=L||o>=P?O(v(n.c),o):T(v(n.c),o,"0"):10===e?t=T(v((n=Q(new G(n),R+o+1,x)).c),n.e,"0"):(b(e,2,V.length,"Base"),t=r(T(v(n.c),o,"0"),10,e,i,!0)),i<0&&n.c[0]&&(t="-"+t)),t},w.valueOf=w.toJSON=function(){return J(this)},w._isBigNumber=!0,null!=t&&G.set(t),G}()).default=o.BigNumber=o,void 0===(r=function(){return o}.call(t,n,t,e))||(e.exports=r);}();},function(e,t,n){var r=n(8),i=n(0).document,o=r(i)&&r(i.createElement);e.exports=function(e){return o?i.createElement(e):{}};},function(e,t,n){var r=n(8);e.exports=function(e,t){if(!r(e))return e;var n,i;if(t&&"function"==typeof(n=e.toString)&&!r(i=n.call(e)))return i;if("function"==typeof(n=e.valueOf)&&!r(i=n.call(e)))return i;if(!t&&"function"==typeof(n=e.toString)&&!r(i=n.call(e)))return i;throw TypeError("Can't convert object to primitive value")};},function(e,t){var n=Math.ceil,r=Math.floor;e.exports=function(e){return isNaN(e=+e)?0:(e>0?r:n)(e)};},function(e,t){e.exports=function(e){if(null==e)throw TypeError("Can't call method on  "+e);return e};},function(e,t,n){var r=n(3),i=n(75),o=n(37),s=n(35)("IE_PROTO"),u=function(){},a=function(){var e,t=n(29)("iframe"),r=o.length;for(t.style.display="none",n(52).appendChild(t),t.src="javascript:",(e=t.contentWindow.document).open(),e.write("<script>document.F=Object<\/script>"),e.close(),a=e.F;r--;)delete a.prototype[o[r]];return a()};e.exports=Object.create||function(e,t){var n;return null!==e?(u.prototype=r(e),n=new u,u.prototype=null,n[s]=e):n=a(),void 0===t?n:i(n,t)};},function(e,t,n){var r=n(50),i=n(37);e.exports=Object.keys||function(e){return r(e,i)};},function(e,t,n){var r=n(36)("keys"),i=n(24);e.exports=function(e){return r[e]||(r[e]=i(e))};},function(e,t,n){var r=n(2),i=n(0),o=i["__core-js_shared__"]||(i["__core-js_shared__"]={});(e.exports=function(e,t){return o[e]||(o[e]=void 0!==t?t:{})})("versions",[]).push({version:r.version,mode:n(17)?"pure":"global",copyright:"© 2019 Denis Pushkarev (zloirock.ru)"});},function(e,t){e.exports="constructor,hasOwnProperty,isPrototypeOf,propertyIsEnumerable,toLocaleString,toString,valueOf".split(",");},function(e,t,n){t.f=n(1);},function(e,t,n){var r=n(0),i=n(2),o=n(17),s=n(38),u=n(7).f;e.exports=function(e){var t=i.Symbol||(i.Symbol=o?{}:r.Symbol||{});"_"==e.charAt(0)||e in t||u(t,e,{value:s.f(e)});};},function(e,t){t.f={}.propertyIsEnumerable;},function(e,t,n){e.exports=n(100);},function(e,t,n){t.__esModule=!0;var r,i=n(102),o=(r=i)&&r.__esModule?r:{default:r};t.default=function(e){return function(){var t=e.apply(this,arguments);return new o.default(function(e,n){return function r(i,s){try{var u=t[i](s),a=u.value;}catch(e){return void n(e)}if(!u.done)return o.default.resolve(a).then(function(e){r("next",e);},function(e){r("throw",e);});e(a);}("next")})}};},function(e,t,n){var r=n(21);function i(e){var t,n;this.promise=new e(function(e,r){if(void 0!==t||void 0!==n)throw TypeError("Bad Promise constructor");t=e,n=r;}),this.resolve=r(t),this.reject=r(n);}e.exports.f=function(e){return new i(e)};},function(e){e.exports={name:"nertcMini",version:"4.6.10",description:"nertc mini SDK 网易云信",main:"index.js",directories:{test:"test"},scripts:{clean:"node build/emptyDist.js","build:sdk":"cross-env PLATFORM=all webpack --config webpack.config.js","build:sdk:stats":"webpack --profile --json > dist/webpack-stats.json","build:api":"node build/api","watch:sdk":"npm run build:sdk -- -w","zip:api":"cross-env NODE_ENV=production npm run build:api && node build/api/zip.js","zip:sdk":"cross-env NODE_ENV=production node build/sdk/zip.js",dev:"npm run clean && run-p watch:*","dev:prod":"cross-env NODE_ENV=production npm run dev",pack:"npm run clean && npm run build:sdk && npm run build:api","pack:test":"cross-env NODE_ENV=test npm run pack","pack:prod":"cross-env NODE_ENV=production npm run pack && npm run zip:sdk"},author:"wulong",license:"ISC",dependencies:{axios:"^0.18.0","babel-polyfill":"^6.26.0",backo2:"^1.0.2","big-integer":"^1.6.48","bigint-hash":"^0.2.2",bignumber:"^1.1.0","bignumber.js":"^9.0.1","crypto-js":"^4.0.0","deep-access":"^0.1.1","es6-promise":"^4.2.4",eventemitter3:"^2.0.2",gulp:"^3.9.1","gulp-jsdoc3":"^2.0.0",happypack:"^5.0.1","javascript-natural-sort":"^0.7.1",jsdoc:"^3.5.5","json-bigint":"^1.0.0",md5:"^2.2.1","string-replace-loader":"^3.0.1",ws:"^5.1.1",x2js:"^3.2.1",xhr:"^2.4.1"},devDependencies:{"@types/debug":"^4.1.5","@types/events":"^3.0.0",archiver:"^2.1.1",awaitqueue:"^2.2.3","babel-core":"^6.26.0","babel-loader":"^7.1.4","babel-plugin-add-module-exports":"^0.2.1","babel-plugin-transform-async-to-generator":"^6.24.1","babel-plugin-transform-es3-member-expression-literals":"^6.22.0","babel-plugin-transform-es3-property-literals":"^6.22.0","babel-plugin-transform-runtime":"^6.23.0","babel-preset-env":"^1.6.1","babel-preset-stage-2":"^6.24.1",bowser:"^2.9.0","cross-env":"^5.1.4","crypto-js":"^4.0.0",debug:"^4.1.1",eslint:"^4.19.1","eslint-config-standard":"^11.0.0","eslint-plugin-import":"^2.11.0","eslint-plugin-node":"^6.0.1","eslint-plugin-promise":"^3.7.0","eslint-plugin-standard":"^3.1.0",events:"^3.1.0","fs-extra":"^5.0.0","imports-loader":"^0.8.0","ink-docstrap":"^1.3.2","npm-run-all":"^4.1.2","on-build-webpack":"^0.1.0","pre-build-webpack":"^0.1.0",prettyjson:"^1.1.3","raw-loader":"^0.5.1","sdp-transform":"^2.14.0","supports-color":"^7.1.0","watch-cli":"^0.2.3",webpack:"^4.5.0","webpack-cli":"^3.3.12","webpack-merge":"^4.1.2","wolfy87-eventemitter":"^5.2.4",yaml:"^0.3.0",yargs:"^11.0.0"}};},function(e,t,n){e.exports={default:n(69),__esModule:!0};},function(e,t,n){e.exports=!n(9)&&!n(22)(function(){return 7!=Object.defineProperty(n(29)("div"),"a",{get:function(){return 7}}).a});},function(e,t,n){var r=n(73)(!0);n(48)(String,"String",function(e){this._t=String(e),this._i=0;},function(){var e,t=this._t,n=this._i;return n>=t.length?{value:void 0,done:!0}:(e=r(t,n),this._i+=e.length,{value:e,done:!1})});},function(e,t,n){var r=n(17),i=n(6),o=n(49),s=n(10),u=n(18),a=n(74),c=n(25),l=n(79),f=n(1)("iterator"),d=!([].keys&&"next"in[].keys()),p=function(){return this};e.exports=function(e,t,n,h,g,_,m){a(n,t,h);var v,y,b,E=function(e){if(!d&&e in A)return A[e];switch(e){case"keys":case"values":return function(){return new n(this,e)}}return function(){return new n(this,e)}},O=t+" Iterator",T="values"==g,k=!1,A=e.prototype,N=A[f]||A["@@iterator"]||g&&A[g],I=N||E(g),C=g?T?E("entries"):I:void 0,w="Array"==t&&A.entries||N;if(w&&(b=l(w.call(new e)))!==Object.prototype&&b.next&&(c(b,O,!0),r||"function"==typeof b[f]||s(b,f,p)),T&&N&&"values"!==N.name&&(k=!0,I=function(){return N.call(this)}),r&&!m||!d&&!k&&A[f]||s(A,f,I),u[t]=I,u[O]=p,g)if(v={values:T?I:E("values"),keys:_?I:E("keys"),entries:C},m)for(y in v)y in A||o(A,y,v[y]);else i(i.P+i.F*(d||k),t,v);return v};},function(e,t,n){e.exports=n(10);},function(e,t,n){var r=n(11),i=n(13),o=n(77)(!1),s=n(35)("IE_PROTO");e.exports=function(e,t){var n,u=i(e),a=0,c=[];for(n in u)n!=s&&r(u,n)&&c.push(n);for(;t.length>a;)r(u,n=t[a++])&&(~o(c,n)||c.push(n));return c};},function(e,t,n){var r=n(31),i=Math.min;e.exports=function(e){return e>0?i(r(e),9007199254740991):0};},function(e,t,n){var r=n(0).document;e.exports=r&&r.documentElement;},function(e,t,n){var r=n(32);e.exports=function(e){return Object(r(e))};},function(e,t,n){n(80);for(var r=n(0),i=n(10),o=n(18),s=n(1)("toStringTag"),u="CSSRuleList,CSSStyleDeclaration,CSSValueList,ClientRectList,DOMRectList,DOMStringList,DOMTokenList,DataTransferItemList,FileList,HTMLAllCollection,HTMLCollection,HTMLFormElement,HTMLSelectElement,MediaList,MimeTypeArray,NamedNodeMap,NodeList,PaintRequestList,Plugin,PluginArray,SVGLengthList,SVGNumberList,SVGPathSegList,SVGPointList,SVGStringList,SVGTransformList,SourceBufferList,StyleSheetList,TextTrackCueList,TextTrackList,TouchList".split(","),a=0;a<u.length;a++){var c=u[a],l=r[c],f=l&&l.prototype;f&&!f[s]&&i(f,s,c),o[c]=o.Array;}},function(e,t){t.f=Object.getOwnPropertySymbols;},function(e,t,n){var r=n(50),i=n(37).concat("length","prototype");t.f=Object.getOwnPropertyNames||function(e){return r(e,i)};},function(e,t,n){var r=n(40),i=n(23),o=n(13),s=n(30),u=n(11),a=n(46),c=Object.getOwnPropertyDescriptor;t.f=n(9)?c:function(e,t){if(e=o(e),t=s(t,!0),a)try{return c(e,t)}catch(e){}if(u(e,t))return i(!r.f.call(e,t),e[t])};},function(e,t){},function(e,t,n){var r=n(19),i=n(1)("toStringTag"),o="Arguments"==r(function(){return arguments}());e.exports=function(e){var t,n,s;return void 0===e?"Undefined":null===e?"Null":"string"==typeof(n=function(e,t){try{return e[t]}catch(e){}}(t=Object(e),i))?n:o?r(t):"Object"==(s=r(t))&&"function"==typeof t.callee?"Arguments":s};},function(e,t,n){var r=n(3),i=n(21),o=n(1)("species");e.exports=function(e,t){var n,s=r(e).constructor;return void 0===s||null==(n=r(s)[o])?t:i(n)};},function(e,t,n){var r,i,o,s=n(15),u=n(110),a=n(52),c=n(29),l=n(0),f=l.process,d=l.setImmediate,p=l.clearImmediate,h=l.MessageChannel,g=l.Dispatch,_=0,m={},v=function(){var e=+this;if(m.hasOwnProperty(e)){var t=m[e];delete m[e],t();}},y=function(e){v.call(e.data);};d&&p||(d=function(e){for(var t=[],n=1;arguments.length>n;)t.push(arguments[n++]);return m[++_]=function(){u("function"==typeof e?e:Function(e),t);},r(_),_},p=function(e){delete m[e];},"process"==n(19)(f)?r=function(e){f.nextTick(s(v,e,1));}:g&&g.now?r=function(e){g.now(s(v,e,1));}:h?(o=(i=new h).port2,i.port1.onmessage=y,r=s(o.postMessage,o,1)):l.addEventListener&&"function"==typeof postMessage&&!l.importScripts?(r=function(e){l.postMessage(e+"","*");},l.addEventListener("message",y,!1)):r="onreadystatechange"in c("script")?function(e){a.appendChild(c("script")).onreadystatechange=function(){a.removeChild(this),v.call(e);};}:function(e){setTimeout(s(v,e,1),0);}),e.exports={set:d,clear:p};},function(e,t){e.exports=function(e){try{return {e:!1,v:e()}}catch(e){return {e:!0,v:e}}};},function(e,t,n){var r=n(3),i=n(8),o=n(43);e.exports=function(e,t){if(r(e),i(t)&&t.constructor===e)return t;var n=o.f(e);return (0, n.resolve)(t),n.promise};},function(e,t,n){var r="https://roomserver.netease.im/v2/sdk/rooms/",i={info:{hash:!1,shortHash:!1,version:"4.6.10"}};console.warn("roomsTaskUrl: ",r),i.miniG2={checkSumUrl:"https://nrtc.netease.im/demo/getChecksum.action",getChannelInfoUrl:"https://nrtc.netease.im/nrtc/getChannelInfos.action",roomsTaskUrl:r},e.exports=i;},function(e,t,n){var r,i,o,s,u;r=n(142),i=n(66).utf8,o=n(143),s=n(66).bin,(u=function(e,t){e.constructor==String?e=t&&"binary"===t.encoding?s.stringToBytes(e):i.stringToBytes(e):o(e)?e=Array.prototype.slice.call(e,0):Array.isArray(e)||(e=e.toString());for(var n=r.bytesToWords(e),a=8*e.length,c=1732584193,l=-271733879,f=-1732584194,d=271733878,p=0;p<n.length;p++)n[p]=16711935&(n[p]<<8|n[p]>>>24)|4278255360&(n[p]<<24|n[p]>>>8);n[a>>>5]|=128<<a%32,n[14+(a+64>>>9<<4)]=a;var h=u._ff,g=u._gg,_=u._hh,m=u._ii;for(p=0;p<n.length;p+=16){var v=c,y=l,b=f,E=d;c=h(c,l,f,d,n[p+0],7,-680876936),d=h(d,c,l,f,n[p+1],12,-389564586),f=h(f,d,c,l,n[p+2],17,606105819),l=h(l,f,d,c,n[p+3],22,-1044525330),c=h(c,l,f,d,n[p+4],7,-176418897),d=h(d,c,l,f,n[p+5],12,1200080426),f=h(f,d,c,l,n[p+6],17,-1473231341),l=h(l,f,d,c,n[p+7],22,-45705983),c=h(c,l,f,d,n[p+8],7,1770035416),d=h(d,c,l,f,n[p+9],12,-1958414417),f=h(f,d,c,l,n[p+10],17,-42063),l=h(l,f,d,c,n[p+11],22,-1990404162),c=h(c,l,f,d,n[p+12],7,1804603682),d=h(d,c,l,f,n[p+13],12,-40341101),f=h(f,d,c,l,n[p+14],17,-1502002290),c=g(c,l=h(l,f,d,c,n[p+15],22,1236535329),f,d,n[p+1],5,-165796510),d=g(d,c,l,f,n[p+6],9,-1069501632),f=g(f,d,c,l,n[p+11],14,643717713),l=g(l,f,d,c,n[p+0],20,-373897302),c=g(c,l,f,d,n[p+5],5,-701558691),d=g(d,c,l,f,n[p+10],9,38016083),f=g(f,d,c,l,n[p+15],14,-660478335),l=g(l,f,d,c,n[p+4],20,-405537848),c=g(c,l,f,d,n[p+9],5,568446438),d=g(d,c,l,f,n[p+14],9,-1019803690),f=g(f,d,c,l,n[p+3],14,-187363961),l=g(l,f,d,c,n[p+8],20,1163531501),c=g(c,l,f,d,n[p+13],5,-1444681467),d=g(d,c,l,f,n[p+2],9,-51403784),f=g(f,d,c,l,n[p+7],14,1735328473),c=_(c,l=g(l,f,d,c,n[p+12],20,-1926607734),f,d,n[p+5],4,-378558),d=_(d,c,l,f,n[p+8],11,-2022574463),f=_(f,d,c,l,n[p+11],16,1839030562),l=_(l,f,d,c,n[p+14],23,-35309556),c=_(c,l,f,d,n[p+1],4,-1530992060),d=_(d,c,l,f,n[p+4],11,1272893353),f=_(f,d,c,l,n[p+7],16,-155497632),l=_(l,f,d,c,n[p+10],23,-1094730640),c=_(c,l,f,d,n[p+13],4,681279174),d=_(d,c,l,f,n[p+0],11,-358537222),f=_(f,d,c,l,n[p+3],16,-722521979),l=_(l,f,d,c,n[p+6],23,76029189),c=_(c,l,f,d,n[p+9],4,-640364487),d=_(d,c,l,f,n[p+12],11,-421815835),f=_(f,d,c,l,n[p+15],16,530742520),c=m(c,l=_(l,f,d,c,n[p+2],23,-995338651),f,d,n[p+0],6,-198630844),d=m(d,c,l,f,n[p+7],10,1126891415),f=m(f,d,c,l,n[p+14],15,-1416354905),l=m(l,f,d,c,n[p+5],21,-57434055),c=m(c,l,f,d,n[p+12],6,1700485571),d=m(d,c,l,f,n[p+3],10,-1894986606),f=m(f,d,c,l,n[p+10],15,-1051523),l=m(l,f,d,c,n[p+1],21,-2054922799),c=m(c,l,f,d,n[p+8],6,1873313359),d=m(d,c,l,f,n[p+15],10,-30611744),f=m(f,d,c,l,n[p+6],15,-1560198380),l=m(l,f,d,c,n[p+13],21,1309151649),c=m(c,l,f,d,n[p+4],6,-145523070),d=m(d,c,l,f,n[p+11],10,-1120210379),f=m(f,d,c,l,n[p+2],15,718787259),l=m(l,f,d,c,n[p+9],21,-343485551),c=c+v>>>0,l=l+y>>>0,f=f+b>>>0,d=d+E>>>0;}return r.endian([c,l,f,d])})._ff=function(e,t,n,r,i,o,s){var u=e+(t&n|~t&r)+(i>>>0)+s;return (u<<o|u>>>32-o)+t},u._gg=function(e,t,n,r,i,o,s){var u=e+(t&r|n&~r)+(i>>>0)+s;return (u<<o|u>>>32-o)+t},u._hh=function(e,t,n,r,i,o,s){var u=e+(t^n^r)+(i>>>0)+s;return (u<<o|u>>>32-o)+t},u._ii=function(e,t,n,r,i,o,s){var u=e+(n^(t|~r))+(i>>>0)+s;return (u<<o|u>>>32-o)+t},u._blocksize=16,u._digestsize=16,e.exports=function(e,t){if(null==e)throw new Error("Illegal argument "+e);var n=r.wordsToBytes(u(e,t));return t&&t.asBytes?n:t&&t.asString?s.bytesToString(n):r.bytesToHex(n)};},function(e,t){var n={utf8:{stringToBytes:function(e){return n.bin.stringToBytes(unescape(encodeURIComponent(e)))},bytesToString:function(e){return decodeURIComponent(escape(n.bin.bytesToString(e)))}},bin:{stringToBytes:function(e){for(var t=[],n=0;n<e.length;n++)t.push(255&e.charCodeAt(n));return t},bytesToString:function(e){for(var t=[],n=0;n<e.length;n++)t.push(String.fromCharCode(e[n]));return t.join("")}}};e.exports=n;},function(e,t,n){var r=n(68);e.exports=r.YunXinMiniappSDK;},function(e,t,n){Object.defineProperty(t,"__esModule",{value:!0}),t.YunXinMiniappSDK=void 0;var r=f(n(4)),i=f(n(5)),o=f(n(16)),s=f(n(20)),u=f(n(99)),a=f(n(27)),c=f(n(140)),l=n(14);function f(e){return e&&e.__esModule?e:{default:e}}t.YunXinMiniappSDK=function(e){function t(e){(0, r.default)(this,t);var n=(0, o.default)(this,(t.__proto__||Object.getPrototypeOf(t)).call(this,e));return a.default.verifyOptions(e,"appkey"),Object.assign(u.default.prototype,c.default),n._init({appkey:e.appkey,nim:e.nim,logger:n.logger}),t.VOICE_BEAUTIFIER_OFF=l.VOICE_BEAUTIFIER_TYPE.VOICE_BEAUTIFIER_OFF,t.VOICE_BEAUTIFIER_MUFFLED=l.VOICE_BEAUTIFIER_TYPE.VOICE_BEAUTIFIER_MUFFLED,t.VOICE_BEAUTIFIER_MELLOW=l.VOICE_BEAUTIFIER_TYPE.VOICE_BEAUTIFIER_MELLOW,t.VOICE_BEAUTIFIER_CLEAR=l.VOICE_BEAUTIFIER_TYPE.VOICE_BEAUTIFIER_CLEAR,t.VOICE_BEAUTIFIER_MAGNETIC=l.VOICE_BEAUTIFIER_TYPE.VOICE_BEAUTIFIER_MAGNETIC,t.VOICE_BEAUTIFIER_RECORDINGSTUDIO=l.VOICE_BEAUTIFIER_TYPE.VOICE_BEAUTIFIER_RECORDINGSTUDIO,t.VOICE_BEAUTIFIER_NATURE=l.VOICE_BEAUTIFIER_TYPE.VOICE_BEAUTIFIER_NATURE,t.VOICE_BEAUTIFIER_REMOTE=l.VOICE_BEAUTIFIER_TYPE.VOICE_BEAUTIFIER_REMOTE,t.VOICE_BEAUTIFIER_CHURCH=l.VOICE_BEAUTIFIER_TYPE.VOICE_BEAUTIFIER_CHURCH,t.VOICE_BEAUTIFIER_BEDROOM=l.VOICE_BEAUTIFIER_TYPE.VOICE_BEAUTIFIER_BEDROOM,t.VOICE_BEAUTIFIER_LIVE=l.VOICE_BEAUTIFIER_TYPE.VOICE_BEAUTIFIER_LIVE,t.AUDIO_EFFECT_OFF=l.VOICE_EFFECT_TYPE.AUDIO_EFFECT_OFF,t.VOICE_CHANGER_EFFECT_ROBOT=l.VOICE_EFFECT_TYPE.VOICE_CHANGER_EFFECT_ROBOT,t.VOICE_CHANGER_EFFECT_GIANT=l.VOICE_EFFECT_TYPE.VOICE_CHANGER_EFFECT_GIANT,t.VOICE_CHANGER_EFFECT_HORROR=l.VOICE_EFFECT_TYPE.VOICE_CHANGER_EFFECT_HORROR,t.VOICE_CHANGER_EFFECT_MATURE=l.VOICE_EFFECT_TYPE.VOICE_CHANGER_EFFECT_MATURE,t.VOICE_CHANGER_EFFECT_MANTOWOMAN=l.VOICE_EFFECT_TYPE.VOICE_CHANGER_EFFECT_MANTOWOMAN,t.VOICE_CHANGER_EFFECT_WOMANTOMAN=l.VOICE_EFFECT_TYPE.VOICE_CHANGER_EFFECT_WOMANTOMAN,t.VOICE_CHANGER_EFFECT_MANTOLOLI=l.VOICE_EFFECT_TYPE.VOICE_CHANGER_EFFECT_MANTOLOLI,t.VOICE_CHANGER_EFFECT_WOMANTOLOLI=l.VOICE_EFFECT_TYPE.VOICE_CHANGER_EFFECT_WOMANTOLOLI,t.AUDIO_EQUALIZATION_BAND_31=l.AUDIO_EQUALIZATION_BAND.AUDIO_EQUALIZATION_BAND_31,t.AUDIO_EQUALIZATION_BAND_62=l.AUDIO_EQUALIZATION_BAND.AUDIO_EQUALIZATION_BAND_62,t.AUDIO_EQUALIZATION_BAND_125=l.AUDIO_EQUALIZATION_BAND.AUDIO_EQUALIZATION_BAND_125,t.AUDIO_EQUALIZATION_BAND_250=l.AUDIO_EQUALIZATION_BAND.AUDIO_EQUALIZATION_BAND_250,t.AUDIO_EQUALIZATION_BAND_500=l.AUDIO_EQUALIZATION_BAND.AUDIO_EQUALIZATION_BAND_500,t.AUDIO_EQUALIZATION_BAND_1K=l.AUDIO_EQUALIZATION_BAND.AUDIO_EQUALIZATION_BAND_1K,t.AUDIO_EQUALIZATION_BAND_2K=l.AUDIO_EQUALIZATION_BAND.AUDIO_EQUALIZATION_BAND_2K,t.AUDIO_EQUALIZATION_BAND_4K=l.AUDIO_EQUALIZATION_BAND.AUDIO_EQUALIZATION_BAND_4K,t.AUDIO_EQUALIZATION_BAND_8K=l.AUDIO_EQUALIZATION_BAND.AUDIO_EQUALIZATION_BAND_8K,t.AUDIO_EQUALIZATION_BAND_16K=l.AUDIO_EQUALIZATION_BAND.AUDIO_EQUALIZATION_BAND_16K,n}return (0, s.default)(t,e),(0, i.default)(t,null,[{key:"Client",value:function(e){return t.instance?t.instance:t.instance=new t(e)}},{key:"destroy",value:function(){t.instance=null;}}]),t}(u.default);},function(e,t,n){n(70);var r=n(2).Object;e.exports=function(e,t,n){return r.defineProperty(e,t,n)};},function(e,t,n){var r=n(6);r(r.S+r.F*!n(9),"Object",{defineProperty:n(7).f});},function(e,t,n){e.exports={default:n(72),__esModule:!0};},function(e,t,n){n(47),n(54),e.exports=n(38).f("iterator");},function(e,t,n){var r=n(31),i=n(32);e.exports=function(e){return function(t,n){var o,s,u=String(i(t)),a=r(n),c=u.length;return a<0||a>=c?e?"":void 0:(o=u.charCodeAt(a))<55296||o>56319||a+1===c||(s=u.charCodeAt(a+1))<56320||s>57343?e?u.charAt(a):o:e?u.slice(a,a+2):s-56320+(o-55296<<10)+65536}};},function(e,t,n){var r=n(33),i=n(23),o=n(25),s={};n(10)(s,n(1)("iterator"),function(){return this}),e.exports=function(e,t,n){e.prototype=r(s,{next:i(1,n)}),o(e,t+" Iterator");};},function(e,t,n){var r=n(7),i=n(3),o=n(34);e.exports=n(9)?Object.defineProperties:function(e,t){i(e);for(var n,s=o(t),u=s.length,a=0;u>a;)r.f(e,n=s[a++],t[n]);return e};},function(e,t,n){var r=n(19);e.exports=Object("z").propertyIsEnumerable(0)?Object:function(e){return "String"==r(e)?e.split(""):Object(e)};},function(e,t,n){var r=n(13),i=n(51),o=n(78);e.exports=function(e){return function(t,n,s){var u,a=r(t),c=i(a.length),l=o(s,c);if(e&&n!=n){for(;c>l;)if((u=a[l++])!=u)return !0}else for(;c>l;l++)if((e||l in a)&&a[l]===n)return e||l||0;return !e&&-1}};},function(e,t,n){var r=n(31),i=Math.max,o=Math.min;e.exports=function(e,t){return (e=r(e))<0?i(e+t,0):o(e,t)};},function(e,t,n){var r=n(11),i=n(53),o=n(35)("IE_PROTO"),s=Object.prototype;e.exports=Object.getPrototypeOf||function(e){return e=i(e),r(e,o)?e[o]:"function"==typeof e.constructor&&e instanceof e.constructor?e.constructor.prototype:e instanceof Object?s:null};},function(e,t,n){var r=n(81),i=n(82),o=n(18),s=n(13);e.exports=n(48)(Array,"Array",function(e,t){this._t=s(e),this._i=0,this._k=t;},function(){var e=this._t,t=this._k,n=this._i++;return !e||n>=e.length?(this._t=void 0,i(1)):i(0,"keys"==t?n:"values"==t?e[n]:[n,e[n]])},"values"),o.Arguments=o.Array,r("keys"),r("values"),r("entries");},function(e,t){e.exports=function(){};},function(e,t){e.exports=function(e,t){return {value:t,done:!!e}};},function(e,t,n){e.exports={default:n(84),__esModule:!0};},function(e,t,n){n(85),n(58),n(90),n(91),e.exports=n(2).Symbol;},function(e,t,n){var r=n(0),i=n(11),o=n(9),s=n(6),u=n(49),a=n(86).KEY,c=n(22),l=n(36),f=n(25),d=n(24),p=n(1),h=n(38),g=n(39),_=n(87),m=n(88),v=n(3),y=n(8),b=n(53),E=n(13),O=n(30),T=n(23),k=n(33),A=n(89),N=n(57),I=n(55),C=n(7),w=n(34),S=N.f,R=C.f,x=A.f,L=r.Symbol,P=r.JSON,F=P&&P.stringify,U=p("_hidden"),D=p("toPrimitive"),j={}.propertyIsEnumerable,B=l("symbol-registry"),M=l("symbols"),V=l("op-symbols"),G=Object.prototype,H="function"==typeof L&&!!I.f,q=r.QObject,Z=!q||!q.prototype||!q.prototype.findChild,Q=o&&c(function(){return 7!=k(R({},"a",{get:function(){return R(this,"a",{value:7}).a}})).a})?function(e,t,n){var r=S(G,t);r&&delete G[t],R(e,t,n),r&&e!==G&&R(G,t,r);}:R,J=function(e){var t=M[e]=k(L.prototype);return t._k=e,t},Y=H&&"symbol"==typeof L.iterator?function(e){return "symbol"==typeof e}:function(e){return e instanceof L},z=function(e,t,n){return e===G&&z(V,t,n),v(e),t=O(t,!0),v(n),i(M,t)?(n.enumerable?(i(e,U)&&e[U][t]&&(e[U][t]=!1),n=k(n,{enumerable:T(0,!1)})):(i(e,U)||R(e,U,T(1,{})),e[U][t]=!0),Q(e,t,n)):R(e,t,n)},W=function(e,t){v(e);for(var n,r=_(t=E(t)),i=0,o=r.length;o>i;)z(e,n=r[i++],t[n]);return e},K=function(e){var t=j.call(this,e=O(e,!0));return !(this===G&&i(M,e)&&!i(V,e))&&(!(t||!i(this,e)||!i(M,e)||i(this,U)&&this[U][e])||t)},$=function(e,t){if(e=E(e),t=O(t,!0),e!==G||!i(M,t)||i(V,t)){var n=S(e,t);return !n||!i(M,t)||i(e,U)&&e[U][t]||(n.enumerable=!0),n}},X=function(e){for(var t,n=x(E(e)),r=[],o=0;n.length>o;)i(M,t=n[o++])||t==U||t==a||r.push(t);return r},ee=function(e){for(var t,n=e===G,r=x(n?V:E(e)),o=[],s=0;r.length>s;)!i(M,t=r[s++])||n&&!i(G,t)||o.push(M[t]);return o};H||(u((L=function(){if(this instanceof L)throw TypeError("Symbol is not a constructor!");var e=d(arguments.length>0?arguments[0]:void 0),t=function(n){this===G&&t.call(V,n),i(this,U)&&i(this[U],e)&&(this[U][e]=!1),Q(this,e,T(1,n));};return o&&Z&&Q(G,e,{configurable:!0,set:t}),J(e)}).prototype,"toString",function(){return this._k}),N.f=$,C.f=z,n(56).f=A.f=X,n(40).f=K,I.f=ee,o&&!n(17)&&u(G,"propertyIsEnumerable",K,!0),h.f=function(e){return J(p(e))}),s(s.G+s.W+s.F*!H,{Symbol:L});for(var te="hasInstance,isConcatSpreadable,iterator,match,replace,search,species,split,toPrimitive,toStringTag,unscopables".split(","),ne=0;te.length>ne;)p(te[ne++]);for(var re=w(p.store),ie=0;re.length>ie;)g(re[ie++]);s(s.S+s.F*!H,"Symbol",{for:function(e){return i(B,e+="")?B[e]:B[e]=L(e)},keyFor:function(e){if(!Y(e))throw TypeError(e+" is not a symbol!");for(var t in B)if(B[t]===e)return t},useSetter:function(){Z=!0;},useSimple:function(){Z=!1;}}),s(s.S+s.F*!H,"Object",{create:function(e,t){return void 0===t?k(e):W(k(e),t)},defineProperty:z,defineProperties:W,getOwnPropertyDescriptor:$,getOwnPropertyNames:X,getOwnPropertySymbols:ee});var oe=c(function(){I.f(1);});s(s.S+s.F*oe,"Object",{getOwnPropertySymbols:function(e){return I.f(b(e))}}),P&&s(s.S+s.F*(!H||c(function(){var e=L();return "[null]"!=F([e])||"{}"!=F({a:e})||"{}"!=F(Object(e))})),"JSON",{stringify:function(e){for(var t,n,r=[e],i=1;arguments.length>i;)r.push(arguments[i++]);if(n=t=r[1],(y(t)||void 0!==e)&&!Y(e))return m(t)||(t=function(e,t){if("function"==typeof n&&(t=n.call(this,e,t)),!Y(t))return t}),r[1]=t,F.apply(P,r)}}),L.prototype[D]||n(10)(L.prototype,D,L.prototype.valueOf),f(L,"Symbol"),f(Math,"Math",!0),f(r.JSON,"JSON",!0);},function(e,t,n){var r=n(24)("meta"),i=n(8),o=n(11),s=n(7).f,u=0,a=Object.isExtensible||function(){return !0},c=!n(22)(function(){return a(Object.preventExtensions({}))}),l=function(e){s(e,r,{value:{i:"O"+ ++u,w:{}}});},f=e.exports={KEY:r,NEED:!1,fastKey:function(e,t){if(!i(e))return "symbol"==typeof e?e:("string"==typeof e?"S":"P")+e;if(!o(e,r)){if(!a(e))return "F";if(!t)return "E";l(e);}return e[r].i},getWeak:function(e,t){if(!o(e,r)){if(!a(e))return !0;if(!t)return !1;l(e);}return e[r].w},onFreeze:function(e){return c&&f.NEED&&a(e)&&!o(e,r)&&l(e),e}};},function(e,t,n){var r=n(34),i=n(55),o=n(40);e.exports=function(e){var t=r(e),n=i.f;if(n)for(var s,u=n(e),a=o.f,c=0;u.length>c;)a.call(e,s=u[c++])&&t.push(s);return t};},function(e,t,n){var r=n(19);e.exports=Array.isArray||function(e){return "Array"==r(e)};},function(e,t,n){var r=n(13),i=n(56).f,o={}.toString,s="object"==typeof window&&window&&Object.getOwnPropertyNames?Object.getOwnPropertyNames(window):[];e.exports.f=function(e){return s&&"[object Window]"==o.call(e)?function(e){try{return i(e)}catch(e){return s.slice()}}(e):i(r(e))};},function(e,t,n){n(39)("asyncIterator");},function(e,t,n){n(39)("observable");},function(e,t,n){e.exports={default:n(93),__esModule:!0};},function(e,t,n){n(94),e.exports=n(2).Object.setPrototypeOf;},function(e,t,n){var r=n(6);r(r.S,"Object",{setPrototypeOf:n(95).set});},function(e,t,n){var r=n(8),i=n(3),o=function(e,t){if(i(e),!r(t)&&null!==t)throw TypeError(t+": can't set as prototype!")};e.exports={set:Object.setPrototypeOf||("__proto__"in{}?function(e,t,r){try{(r=n(15)(Function.call,n(57).f(Object.prototype,"__proto__").set,2))(e,[]),t=!(e instanceof Array);}catch(e){t=!0;}return function(e,n){return o(e,n),t?e.__proto__=n:r(e,n),e}}({},!1):void 0),check:o};},function(e,t,n){e.exports={default:n(97),__esModule:!0};},function(e,t,n){n(98);var r=n(2).Object;e.exports=function(e,t){return r.create(e,t)};},function(e,t,n){var r=n(6);r(r.S,"Object",{create:n(33)});},function(e,t,n){Object.defineProperty(t,"__esModule",{value:!0});var r=_(n(41)),i=_(n(42)),o=_(n(118)),s=_(n(4)),u=_(n(5)),a=_(n(16)),c=_(n(20)),l=_(n(26)),f=_(n(27)),d=_(n(119)),p=_(n(131)),h=n(14),g=n(14);function _(e){return e&&e.__esModule?e:{default:e}}var m=n(132),v=n(28),y=function(e){function t(){var e,n=arguments.length>0&&void 0!==arguments[0]?arguments[0]:{};(0, s.default)(this,t);var r=(0, a.default)(this,(t.__proto__||Object.getPrototypeOf(t)).call(this));return r.logger=new m({debug:n.debug,prefix:"mini"}),r._status={appkey:n.appkey||null,startSessionTime:0,endSessionTime:0,lastSessionDuation:0,publishAudio:!1,publishVideo:!1,channelServer:"",statisticsServer:"",role:"broadcaster",audioChangeMode:0,voiceBeautifierType:g.VOICE_BEAUTIFIER_TYPE.VOICE_BEAUTIFIER_OFF,voiceEffectType:g.VOICE_EFFECT_TYPE.AUDIO_EFFECT_OFF,pitch:"1.25",AudioEqualizationBand:(e={},(0, o.default)(e,g.AUDIO_EQUALIZATION_BAND.AUDIO_EQUALIZATION_BAND_31,0),(0, o.default)(e,g.AUDIO_EQUALIZATION_BAND.AUDIO_EQUALIZATION_BAND_62,0),(0, o.default)(e,g.AUDIO_EQUALIZATION_BAND.AUDIO_EQUALIZATION_BAND_125,0),(0, o.default)(e,g.AUDIO_EQUALIZATION_BAND.AUDIO_EQUALIZATION_BAND_250,0),(0, o.default)(e,g.AUDIO_EQUALIZATION_BAND.AUDIO_EQUALIZATION_BAND_500,0),(0, o.default)(e,g.AUDIO_EQUALIZATION_BAND.AUDIO_EQUALIZATION_BAND_1K,0),(0, o.default)(e,g.AUDIO_EQUALIZATION_BAND.AUDIO_EQUALIZATION_BAND_2K,0),(0, o.default)(e,g.AUDIO_EQUALIZATION_BAND.AUDIO_EQUALIZATION_BAND_4K,0),(0, o.default)(e,g.AUDIO_EQUALIZATION_BAND.AUDIO_EQUALIZATION_BAND_8K,0),(0, o.default)(e,g.AUDIO_EQUALIZATION_BAND.AUDIO_EQUALIZATION_BAND_16K,0),e),runtimeEnvironment:"undefined"==typeof qq?"wechat":"qq"},r._wsController=null,r}return (0, c.default)(t,e),(0, u.default)(t,[{key:"_init",value:function(){var e=arguments.length>0&&void 0!==arguments[0]?arguments[0]:{};this._resetStatus(),Object.assign(this,h.ROLE_FOR_MEETING,h.SESSION_MODE,h.LIVE_ENABLE,h.RECORD_TYPE,h.RECORD_AUDIO,h.RECORD_VIDEO,h.NETCALL_MODE,h.RTMP_RECORD),this._wsController=new d.default(Object.assign(e,{status:this._status})),this._dataReporter=new p.default,this._bindEvent();}},{key:"_resetStatus",value:function(){var e;Object.assign(this._status,{isBigNumberOfLocalUid:!1,joinChannelParam:null,isInTheRoom:!1,createChannelResponse:{},closeEvent:h.CONSTANT_ERROR.closeNormal,rtmpPushAddress:"",audioChangeMode:0,voiceBeautifierType:g.VOICE_BEAUTIFIER_TYPE.VOICE_BEAUTIFIER_OFF,voiceEffectType:g.VOICE_EFFECT_TYPE.AUDIO_EFFECT_OFF,pitch:"1.25",audioEqualizationBand:(e={},(0, o.default)(e,g.AUDIO_EQUALIZATION_BAND.AUDIO_EQUALIZATION_BAND_31,0),(0, o.default)(e,g.AUDIO_EQUALIZATION_BAND.AUDIO_EQUALIZATION_BAND_62,0),(0, o.default)(e,g.AUDIO_EQUALIZATION_BAND.AUDIO_EQUALIZATION_BAND_125,0),(0, o.default)(e,g.AUDIO_EQUALIZATION_BAND.AUDIO_EQUALIZATION_BAND_250,0),(0, o.default)(e,g.AUDIO_EQUALIZATION_BAND.AUDIO_EQUALIZATION_BAND_500,0),(0, o.default)(e,g.AUDIO_EQUALIZATION_BAND.AUDIO_EQUALIZATION_BAND_1K,0),(0, o.default)(e,g.AUDIO_EQUALIZATION_BAND.AUDIO_EQUALIZATION_BAND_2K,0),(0, o.default)(e,g.AUDIO_EQUALIZATION_BAND.AUDIO_EQUALIZATION_BAND_4K,0),(0, o.default)(e,g.AUDIO_EQUALIZATION_BAND.AUDIO_EQUALIZATION_BAND_8K,0),(0, o.default)(e,g.AUDIO_EQUALIZATION_BAND.AUDIO_EQUALIZATION_BAND_16K,0),e)}),this._status.publishAudio=!1,this._status.publishVideo=!1,this._info={pushUrl:"",userlist:new Map,cid:0,uid:0};}},{key:"_updateStatus",value:function(){var e=arguments.length>0&&void 0!==arguments[0]?arguments[0]:{};Object.assign(this._status,e);}},{key:"_bindEvent",value:function(){var e,t=this;this._wsController&&(this._wsController.on("reconnectFailed",function(e){t.apiEventReport("setDisconnect",{reason:"reconnectFailed"}),t._status.closeEvent=h.CONSTANT_ERROR.reconnectFail,t.destroy();}),this._wsController.on("kicked",function(e){t.apiEventReport("setDisconnect",{reason:"kicked"}),t._status.closeEvent=h.CONSTANT_ERROR.kicked,t.emit("kicked",e),t.destroy();}),this._wsController.on("roomRefused",function(e){t._status.closeEvent=h.CONSTANT_ERROR.roomRefused,t.apiEventReport("setDisconnect",{reason:"roomRefused"}),t.emit("kicked",e),t.destroy();}),this._wsController.on("loginFailed",function(e){e?e.code==h.CONSTANT_ERROR.loginFailed.code?t._status.closeEvent=h.CONSTANT_ERROR.loginFailed:e.code===h.CONSTANT_ERROR.loginFailedEncrypt.code&&(t._status.closeEvent=h.CONSTANT_ERROR.loginFailedEncrypt):t._status.closeEvent=h.CONSTANT_ERROR.loginFailed;var n=t._info.joinChannelParam||t._info.createChannelResponse||{};t.apiEventReport("setLogin",{a_record:!!n.recordAudio,v_record:!!n.recordVideo,record_type:n.recordType?n.recordType+"":"0",host_speaker:!!n.isHostSpeaker,result:e.code,serverIp:n.address||""}),t.destroy();}),this._wsController.on("disconnect",function(){var e=Object.assign({},t._status.closeEvent);t.logger.log("mainController::ws ondestroy: ",e),t._resetStatus(),t.emit("disconnect",e),t.apiEventReport("setFunction",{name:"disconnect",oper:"1",value:"failed"});}),this._wsController.on("error",function(e){t.apiEventReport("setDisconnect",{reason:"ws error"}),t.emit("error",e);}),this._wsController.on("syncDone",function(e){t.logger.log("mainController: syncDone 成功:",e);var n="setLogin";t._status.needReconnect&&(n="setRelogin");var r=t._info.joinChannelParam||t._info.createChannelResponse||{};t.apiEventReport(n,{a_record:!!r.recordAudio,v_record:!!r.recordVideo,record_type:r.recordType?r.recordType+"":"0",host_speaker:!!r.isHostSpeaker,result:0,serverIp:r.address||""}),e.userlist.map(function(e){var n=!1;return v.isBigNumber(e.uid)&&(n=!0),n&&v.isBigNumber(t._info.uid)&&e.uid.eq(t._info.uid)||!n&&!v.isBigNumber(t._info.uid)&&e.uid==t._info.uid||e.uid.toString()==t._info.uid.toString()?(t._info.pushUrl&&t._info.pushUrl!==e.url&&(t.logger.log("推流地址发生了变化: ",t._info.pushUrl),t.apiEventReport("setFunction",{name:"syncDone",oper:"1",value:JSON.stringify({uid:t._info.uid,url:e.url,isBigNumber:n},null," ")}),t.emit("syncDone",{uid:t._info.uid,url:e.url,isBigNumber:n})),t._info.pushUrl=e.url,void t.logger.log("推流地址: ",t._info.pushUrl)):(t.logger.log("房间里有其他人: ",e.uid),e.subscribed={userSubAudio:!1,audio:!1,slaveAudio:!1,video:!1,screenShare:!1},t._info.userlist.set(e.uid.toString(),e),1==e.role?void t.logger.log(e.uid+" 为观众角色，忽略"):(t.emit("clientJoin",{uid:e.uid,isBigNumber:n}),(e.audio_on||e.video_on||e.screen_on||e.slaveAudio_on||e.sa_on)&&(e.audio_on&&(t.logger.log(e.uid+" 发布了自己的 audio"),t.emit("stream-added",{uid:n?e.uid.toString():e.uid,mediaType:"audio",isBigNumber:n})),(e.slaveAudio_on||e.sa_on)&&(t.logger.log(e.uid+" 发布了自己的 audioSlave"),t.emit("stream-added",{uid:n?e.uid.toString():e.uid,mediaType:"slaveAudio",isBigNumber:n})),e.video_on&&(t.logger.log(e.uid+" 发布了自己的 video"),t.emit("stream-added",{uid:n?e.uid.toString():e.uid,mediaType:"video",isBigNumber:n})),e.screen_on&&(t.logger.log(e.uid+" 发布了自己的 screenShare"),t.emit("stream-added",{uid:n?e.uid.toString():e.uid,mediaType:"screenShare",isBigNumber:n})),"off"===e.audio_status&&e.audio_on&&t.emit("media-status",{uid:n?e.uid.toString():e.uid,mediaType:"audio",status:"off",isBigNumber:n}),"off"===e.sa_status&&e.sa_on&&t.emit("media-status",{uid:n?e.uid.toString():e.uid,mediaType:"audio",status:"off",isBigNumber:n}),"off"===e.video_status&&e.video_on&&t.emit("media-status",{uid:n?e.uid.toString():e.uid,mediaType:"video",status:"off",isBigNumber:n}),"off"===e.screen_status&&e.screen_on&&t.emit("media-status",{uid:n?e.uid.toString():e.uid,mediaType:"screenShare",status:"off",isBigNumber:n})),e))});}),this._wsController.on("clientLeave",function(e){t.logger.log("有人离开: ",e.uid);var n=!1;v.isBigNumber(e.uid)&&(n=!0),t.emit("clientLeave",{uid:e.uid,isBigNumber:n}),t._info.userlist.delete(e.uid.toString());}),this._wsController.on("clientMute",function(e){t.logger.log("mainController: clientMute 有人mute:",e);var n=!1;v.isBigNumber(e.uid)&&(t.logger.log("mainController: clientMute isBigNumber:",n),n=!0),"audio"==e.mediaType?e.mute?n?t.emit("mute-audio",e.uid.toString):t.emit("mute-audio",e.uid):n?t.emit("unmute-audio",e.uid.toString):t.emit("unmute-audio",e.uid):"video"==e.mediaType&&(e.mute?n?t.emit("mute-video",e.uid.toString):t.emit("mute-video",e.uid):n?t.emit("unmute-video",e.uid.toString):t.emit("unmute-video",e.uid));}),this._wsController.on("clientJoin",function(e){if(e.subscribed={userSubAudio:!1,audio:!1,slaveAudio:!1,video:!1,screenShare:!1},t.logger.log("mainController: clientJoin 有人加入房间:",e),t._info.userlist.set(e.uid.toString(),e),1!=e.role){var n=!1;v.isBigNumber(e.uid)&&(t.logger.log("mainController: clientJoin isBigNumber:",n),n=!0),t.emit("clientJoin",{uid:n?e.uid.toString():e.uid,isBigNumber:n});}else t.logger.log("clientJoin "+e.uid+" 为观众角色，忽略");}),this._wsController.on("clientUpdate",function(e){t.emit("clientUpdate",e);}),this._wsController.on("liveRoomClose",function(e){t.emit("liveRoomClose",e);}),this._wsController.on("willreconnect",function(e){t.apiEventReport("setFunction",{name:"willreconnect",oper:"1",value:JSON.stringify({reconnectCount:t._wsController._status.reconnectCount},null," ")}),t.emit("willreconnect",e);}),this._wsController.on("reconnected",(e=(0, i.default)(r.default.mark(function e(n){return r.default.wrap(function(e){for(;;)switch(e.prev=e.next){case 0:if(t.apiEventReport("setFunction",{name:"reconnected",oper:"1",value:JSON.stringify({reconnectCount:t._wsController._status.reconnectCount},null," ")}),t.setRole(t._status.role),!t._status.publishAudio){e.next=6;break}return t._status.publishAudio=!1,e.next=6,t.publish("audio");case 6:if(!t._status.publishVideo){e.next=10;break}return t._status.publishVideo=!1,e.next=10,t.publish("video");case 10:t.emit("reconnected",n);case 11:case"end":return e.stop()}},e,t)})),function(t){return e.apply(this,arguments)})),this._wsController.on("clientPublished",function(e){var n=!1;if(v.isBigNumber(e.uid)&&(t.logger.log("mainController: clientPublished isBigNumber:",n),n=!0),t.logger.log("clientPublished: ",e),"open"==e.status){if(t.logger.log(e.uid+" 发布了自己的 "+e.mediaType),t.emit("stream-added",{uid:n?e.uid.toString():e.uid,mediaType:e.mediaType,isBigNumber:n}),"slaveAudio"==e.mediaType){var r=t._info.userlist.get(e.uid.toString());r.slaveaudio_url=e.sa_url||e.url,t._info.userlist.set(e.uid.toString(),r);}else if("screenShare"===e.mediaType){var i=t._info.userlist.get(e.uid.toString());i.screen_url=e.url,t._info.userlist.set(e.uid.toString(),i);}}else "close"==e.status&&(t.logger.log(e.uid+" 取消发布了自己的 "+e.mediaType),t.emit("stream-removed",{uid:n?e.uid.toString():e.uid,mediaType:e.mediaType,isBigNumber:n}));}),this._wsController.on("changeRoled",function(e){var n=!1;if(v.isBigNumber(e.uid)&&(t.logger.log("mainController: changeRoled isBigNumber:",n),n=!0),t.emit("role-Changed",{uid:n?e.uid.toString():e.uid,role:e.role,isBigNumber:n}),t.logger.log(e.uid+" 变更了自己的角色: "+e.role),0==e.role)t.logger.log(e.uid+" 变成了观众通知： "+e.role),t.emit("clientJoin",{uid:n?e.uid.toString():e.uid,isBigNumber:n});else if(1==e.role){t._info.userlist.get(e.uid.toString())?(t.logger.log(e.uid+" 变成了直播通知： "+e.role),t.emit("clientLeave",{uid:n?e.uid.toString():e.uid,isBigNumber:n})):t.logger.log("没有此成员，忽略");}}),this._wsController.on("abilityNotSupport",function(e){var n=!1;v.isBigNumber(e.uid)&&(t.logger.log("mainController: abilityNotSupport isBigNumber:",n),n=!0),t.emit("ability-not-support",{uid:n?e.uid.toString():e.uid,code:e.code,errMsg:e.errMsg,isBigNumber:n}),t.logger.warn("房间媒体协商出现问题：: "+e.msg);}),this._wsController.on("clientMediaStatus",function(e){var n=!1;v.isBigNumber(e.uid)&&(t.logger.log("mainController: clientMediaStatus isBigNumber:",n),n=!0),t.emit("media-status",{uid:n?e.uid.toString():e.uid,url:e.url,mediaType:e.mediaType,status:e.status,isBigNumber:n});}),this._wsController.on("rtmpTaskStatus",function(e){console.warn("event: ",e);var n=!1;v.isBigNumber(e.uid)&&(t.logger.log("mainController: rtmpTaskStatus isBigNumber:",n),n=!0),t.emit("rtmp-tasks-status",{uid:n?e.uid.toString():e.uid,hotsUid:n?e.hotsUid.toString():e.hotsUid,streamUrl:e.streamUrl,code:e.code,msg:e.msg,taskId:e.taskId,isBigNumber:n});}),this._wsController.on("sendCommandOverTime",function(e){t.apiEventReport("setDisconnect",{reason:"sendCommandOverTime"}),t.emit("sendCommandOverTime",e);}),this._wsController.on("sessionStart",this.setStartSessionTime.bind(this)),this._wsController.on("sessionEnd",this.setEndSessionTime.bind(this))),this._dataReporter&&this._dataReporter.on("updateStatistics",function(e){t._dataReporter.updateStatistics(e);});}},{key:"destroy",value:function(){this._wsController&&this._wsController._destroy();}},{key:"getStatus",value:function(){return f.default.deepClone(this._status)}},{key:"setStartSessionTime",value:function(){this._status.startSessionTime=+Date.now(),this._status.endSessionTime=0,this.emit("sessionStart");}},{key:"setEndSessionTime",value:function(){this._status.startSessionTime?(this._status.endSessionTime=+Date.now(),this._status.lastSessionDuation=this._status.endSessionTime-this._status.startSessionTime):this.logger.log("mainController: setEndSessionTime failed: startSessionTime undefined！");}}]),t}(l.default);t.default=y,e.exports=t.default;},function(e,t,n){var r=function(){return this}()||Function("return this")(),i=r.regeneratorRuntime&&Object.getOwnPropertyNames(r).indexOf("regeneratorRuntime")>=0,o=i&&r.regeneratorRuntime;if(r.regeneratorRuntime=void 0,e.exports=n(101),i)r.regeneratorRuntime=o;else try{delete r.regeneratorRuntime;}catch(e){r.regeneratorRuntime=void 0;}},function(e,t){!function(t){var n,r=Object.prototype,i=r.hasOwnProperty,o="function"==typeof Symbol?Symbol:{},s=o.iterator||"@@iterator",u=o.asyncIterator||"@@asyncIterator",a=o.toStringTag||"@@toStringTag",c="object"==typeof e,l=t.regeneratorRuntime;if(l)c&&(e.exports=l);else {(l=t.regeneratorRuntime=c?e.exports:{}).wrap=b;var f="suspendedStart",d="suspendedYield",p="executing",h="completed",g={},_={};_[s]=function(){return this};var m=Object.getPrototypeOf,v=m&&m(m(R([])));v&&v!==r&&i.call(v,s)&&(_=v);var y=k.prototype=O.prototype=Object.create(_);T.prototype=y.constructor=k,k.constructor=T,k[a]=T.displayName="GeneratorFunction",l.isGeneratorFunction=function(e){var t="function"==typeof e&&e.constructor;return !!t&&(t===T||"GeneratorFunction"===(t.displayName||t.name))},l.mark=function(e){return Object.setPrototypeOf?Object.setPrototypeOf(e,k):(e.__proto__=k,a in e||(e[a]="GeneratorFunction")),e.prototype=Object.create(y),e},l.awrap=function(e){return {__await:e}},A(N.prototype),N.prototype[u]=function(){return this},l.AsyncIterator=N,l.async=function(e,t,n,r){var i=new N(b(e,t,n,r));return l.isGeneratorFunction(t)?i:i.next().then(function(e){return e.done?e.value:i.next()})},A(y),y[a]="Generator",y[s]=function(){return this},y.toString=function(){return "[object Generator]"},l.keys=function(e){var t=[];for(var n in e)t.push(n);return t.reverse(),function n(){for(;t.length;){var r=t.pop();if(r in e)return n.value=r,n.done=!1,n}return n.done=!0,n}},l.values=R,S.prototype={constructor:S,reset:function(e){if(this.prev=0,this.next=0,this.sent=this._sent=n,this.done=!1,this.delegate=null,this.method="next",this.arg=n,this.tryEntries.forEach(w),!e)for(var t in this)"t"===t.charAt(0)&&i.call(this,t)&&!isNaN(+t.slice(1))&&(this[t]=n);},stop:function(){this.done=!0;var e=this.tryEntries[0].completion;if("throw"===e.type)throw e.arg;return this.rval},dispatchException:function(e){if(this.done)throw e;var t=this;function r(r,i){return u.type="throw",u.arg=e,t.next=r,i&&(t.method="next",t.arg=n),!!i}for(var o=this.tryEntries.length-1;o>=0;--o){var s=this.tryEntries[o],u=s.completion;if("root"===s.tryLoc)return r("end");if(s.tryLoc<=this.prev){var a=i.call(s,"catchLoc"),c=i.call(s,"finallyLoc");if(a&&c){if(this.prev<s.catchLoc)return r(s.catchLoc,!0);if(this.prev<s.finallyLoc)return r(s.finallyLoc)}else if(a){if(this.prev<s.catchLoc)return r(s.catchLoc,!0)}else {if(!c)throw new Error("try statement without catch or finally");if(this.prev<s.finallyLoc)return r(s.finallyLoc)}}}},abrupt:function(e,t){for(var n=this.tryEntries.length-1;n>=0;--n){var r=this.tryEntries[n];if(r.tryLoc<=this.prev&&i.call(r,"finallyLoc")&&this.prev<r.finallyLoc){var o=r;break}}o&&("break"===e||"continue"===e)&&o.tryLoc<=t&&t<=o.finallyLoc&&(o=null);var s=o?o.completion:{};return s.type=e,s.arg=t,o?(this.method="next",this.next=o.finallyLoc,g):this.complete(s)},complete:function(e,t){if("throw"===e.type)throw e.arg;return "break"===e.type||"continue"===e.type?this.next=e.arg:"return"===e.type?(this.rval=this.arg=e.arg,this.method="return",this.next="end"):"normal"===e.type&&t&&(this.next=t),g},finish:function(e){for(var t=this.tryEntries.length-1;t>=0;--t){var n=this.tryEntries[t];if(n.finallyLoc===e)return this.complete(n.completion,n.afterLoc),w(n),g}},catch:function(e){for(var t=this.tryEntries.length-1;t>=0;--t){var n=this.tryEntries[t];if(n.tryLoc===e){var r=n.completion;if("throw"===r.type){var i=r.arg;w(n);}return i}}throw new Error("illegal catch attempt")},delegateYield:function(e,t,r){return this.delegate={iterator:R(e),resultName:t,nextLoc:r},"next"===this.method&&(this.arg=n),g}};}function b(e,t,n,r){var i=t&&t.prototype instanceof O?t:O,o=Object.create(i.prototype),s=new S(r||[]);return o._invoke=function(e,t,n){var r=f;return function(i,o){if(r===p)throw new Error("Generator is already running");if(r===h){if("throw"===i)throw o;return x()}for(n.method=i,n.arg=o;;){var s=n.delegate;if(s){var u=I(s,n);if(u){if(u===g)continue;return u}}if("next"===n.method)n.sent=n._sent=n.arg;else if("throw"===n.method){if(r===f)throw r=h,n.arg;n.dispatchException(n.arg);}else "return"===n.method&&n.abrupt("return",n.arg);r=p;var a=E(e,t,n);if("normal"===a.type){if(r=n.done?h:d,a.arg===g)continue;return {value:a.arg,done:n.done}}"throw"===a.type&&(r=h,n.method="throw",n.arg=a.arg);}}}(e,n,s),o}function E(e,t,n){try{return {type:"normal",arg:e.call(t,n)}}catch(e){return {type:"throw",arg:e}}}function O(){}function T(){}function k(){}function A(e){["next","throw","return"].forEach(function(t){e[t]=function(e){return this._invoke(t,e)};});}function N(e){var t;this._invoke=function(n,r){function o(){return new Promise(function(t,o){!function t(n,r,o,s){var u=E(e[n],e,r);if("throw"!==u.type){var a=u.arg,c=a.value;return c&&"object"==typeof c&&i.call(c,"__await")?Promise.resolve(c.__await).then(function(e){t("next",e,o,s);},function(e){t("throw",e,o,s);}):Promise.resolve(c).then(function(e){a.value=e,o(a);},s)}s(u.arg);}(n,r,t,o);})}return t=t?t.then(o,o):o()};}function I(e,t){var r=e.iterator[t.method];if(r===n){if(t.delegate=null,"throw"===t.method){if(e.iterator.return&&(t.method="return",t.arg=n,I(e,t),"throw"===t.method))return g;t.method="throw",t.arg=new TypeError("The iterator does not provide a 'throw' method");}return g}var i=E(r,e.iterator,t.arg);if("throw"===i.type)return t.method="throw",t.arg=i.arg,t.delegate=null,g;var o=i.arg;return o?o.done?(t[e.resultName]=o.value,t.next=e.nextLoc,"return"!==t.method&&(t.method="next",t.arg=n),t.delegate=null,g):o:(t.method="throw",t.arg=new TypeError("iterator result is not an object"),t.delegate=null,g)}function C(e){var t={tryLoc:e[0]};1 in e&&(t.catchLoc=e[1]),2 in e&&(t.finallyLoc=e[2],t.afterLoc=e[3]),this.tryEntries.push(t);}function w(e){var t=e.completion||{};t.type="normal",delete t.arg,e.completion=t;}function S(e){this.tryEntries=[{tryLoc:"root"}],e.forEach(C,this),this.reset(!0);}function R(e){if(e){var t=e[s];if(t)return t.call(e);if("function"==typeof e.next)return e;if(!isNaN(e.length)){var r=-1,o=function t(){for(;++r<e.length;)if(i.call(e,r))return t.value=e[r],t.done=!1,t;return t.value=n,t.done=!0,t};return o.next=o}}return {next:x}}function x(){return {value:n,done:!0}}}(function(){return this}()||Function("return this")());},function(e,t,n){e.exports={default:n(103),__esModule:!0};},function(e,t,n){n(58),n(47),n(54),n(104),n(116),n(117),e.exports=n(2).Promise;},function(e,t,n){var r,i,o,s,u=n(17),a=n(0),c=n(15),l=n(59),f=n(6),d=n(8),p=n(21),h=n(105),g=n(106),_=n(60),m=n(61).set,v=n(111)(),y=n(43),b=n(62),E=n(112),O=n(63),T=a.TypeError,k=a.process,A=k&&k.versions,N=A&&A.v8||"",I=a.Promise,C="process"==l(k),w=function(){},S=i=y.f,R=!!function(){try{var e=I.resolve(1),t=(e.constructor={})[n(1)("species")]=function(e){e(w,w);};return (C||"function"==typeof PromiseRejectionEvent)&&e.then(w)instanceof t&&0!==N.indexOf("6.6")&&-1===E.indexOf("Chrome/66")}catch(e){}}(),x=function(e){var t;return !(!d(e)||"function"!=typeof(t=e.then))&&t},L=function(e,t){if(!e._n){e._n=!0;var n=e._c;v(function(){for(var r=e._v,i=1==e._s,o=0,s=function(t){var n,o,s,u=i?t.ok:t.fail,a=t.resolve,c=t.reject,l=t.domain;try{u?(i||(2==e._h&&U(e),e._h=1),!0===u?n=r:(l&&l.enter(),n=u(r),l&&(l.exit(),s=!0)),n===t.promise?c(T("Promise-chain cycle")):(o=x(n))?o.call(n,a,c):a(n)):c(r);}catch(e){l&&!s&&l.exit(),c(e);}};n.length>o;)s(n[o++]);e._c=[],e._n=!1,t&&!e._h&&P(e);});}},P=function(e){m.call(a,function(){var t,n,r,i=e._v,o=F(e);if(o&&(t=b(function(){C?k.emit("unhandledRejection",i,e):(n=a.onunhandledrejection)?n({promise:e,reason:i}):(r=a.console)&&r.error&&r.error("Unhandled promise rejection",i);}),e._h=C||F(e)?2:1),e._a=void 0,o&&t.e)throw t.v});},F=function(e){return 1!==e._h&&0===(e._a||e._c).length},U=function(e){m.call(a,function(){var t;C?k.emit("rejectionHandled",e):(t=a.onrejectionhandled)&&t({promise:e,reason:e._v});});},D=function(e){var t=this;t._d||(t._d=!0,(t=t._w||t)._v=e,t._s=2,t._a||(t._a=t._c.slice()),L(t,!0));},j=function(e){var t,n=this;if(!n._d){n._d=!0,n=n._w||n;try{if(n===e)throw T("Promise can't be resolved itself");(t=x(e))?v(function(){var r={_w:n,_d:!1};try{t.call(e,c(j,r,1),c(D,r,1));}catch(e){D.call(r,e);}}):(n._v=e,n._s=1,L(n,!1));}catch(e){D.call({_w:n,_d:!1},e);}}};R||(I=function(e){h(this,I,"Promise","_h"),p(e),r.call(this);try{e(c(j,this,1),c(D,this,1));}catch(e){D.call(this,e);}},(r=function(e){this._c=[],this._a=void 0,this._s=0,this._d=!1,this._v=void 0,this._h=0,this._n=!1;}).prototype=n(113)(I.prototype,{then:function(e,t){var n=S(_(this,I));return n.ok="function"!=typeof e||e,n.fail="function"==typeof t&&t,n.domain=C?k.domain:void 0,this._c.push(n),this._a&&this._a.push(n),this._s&&L(this,!1),n.promise},catch:function(e){return this.then(void 0,e)}}),o=function(){var e=new r;this.promise=e,this.resolve=c(j,e,1),this.reject=c(D,e,1);},y.f=S=function(e){return e===I||e===s?new o(e):i(e)}),f(f.G+f.W+f.F*!R,{Promise:I}),n(25)(I,"Promise"),n(114)("Promise"),s=n(2).Promise,f(f.S+f.F*!R,"Promise",{reject:function(e){var t=S(this);return (0, t.reject)(e),t.promise}}),f(f.S+f.F*(u||!R),"Promise",{resolve:function(e){return O(u&&this===s?I:this,e)}}),f(f.S+f.F*!(R&&n(115)(function(e){I.all(e).catch(w);})),"Promise",{all:function(e){var t=this,n=S(t),r=n.resolve,i=n.reject,o=b(function(){var n=[],o=0,s=1;g(e,!1,function(e){var u=o++,a=!1;n.push(void 0),s++,t.resolve(e).then(function(e){a||(a=!0,n[u]=e,--s||r(n));},i);}),--s||r(n);});return o.e&&i(o.v),n.promise},race:function(e){var t=this,n=S(t),r=n.reject,i=b(function(){g(e,!1,function(e){t.resolve(e).then(n.resolve,r);});});return i.e&&r(i.v),n.promise}});},function(e,t){e.exports=function(e,t,n,r){if(!(e instanceof t)||void 0!==r&&r in e)throw TypeError(n+": incorrect invocation!");return e};},function(e,t,n){var r=n(15),i=n(107),o=n(108),s=n(3),u=n(51),a=n(109),c={},l={};(t=e.exports=function(e,t,n,f,d){var p,h,g,_,m=d?function(){return e}:a(e),v=r(n,f,t?2:1),y=0;if("function"!=typeof m)throw TypeError(e+" is not iterable!");if(o(m)){for(p=u(e.length);p>y;y++)if((_=t?v(s(h=e[y])[0],h[1]):v(e[y]))===c||_===l)return _}else for(g=m.call(e);!(h=g.next()).done;)if((_=i(g,v,h.value,t))===c||_===l)return _}).BREAK=c,t.RETURN=l;},function(e,t,n){var r=n(3);e.exports=function(e,t,n,i){try{return i?t(r(n)[0],n[1]):t(n)}catch(t){var o=e.return;throw void 0!==o&&r(o.call(e)),t}};},function(e,t,n){var r=n(18),i=n(1)("iterator"),o=Array.prototype;e.exports=function(e){return void 0!==e&&(r.Array===e||o[i]===e)};},function(e,t,n){var r=n(59),i=n(1)("iterator"),o=n(18);e.exports=n(2).getIteratorMethod=function(e){if(null!=e)return e[i]||e["@@iterator"]||o[r(e)]};},function(e,t){e.exports=function(e,t,n){var r=void 0===n;switch(t.length){case 0:return r?e():e.call(n);case 1:return r?e(t[0]):e.call(n,t[0]);case 2:return r?e(t[0],t[1]):e.call(n,t[0],t[1]);case 3:return r?e(t[0],t[1],t[2]):e.call(n,t[0],t[1],t[2]);case 4:return r?e(t[0],t[1],t[2],t[3]):e.call(n,t[0],t[1],t[2],t[3])}return e.apply(n,t)};},function(e,t,n){var r=n(0),i=n(61).set,o=r.MutationObserver||r.WebKitMutationObserver,s=r.process,u=r.Promise,a="process"==n(19)(s);e.exports=function(){var e,t,n,c=function(){var r,i;for(a&&(r=s.domain)&&r.exit();e;){i=e.fn,e=e.next;try{i();}catch(r){throw e?n():t=void 0,r}}t=void 0,r&&r.enter();};if(a)n=function(){s.nextTick(c);};else if(!o||r.navigator&&r.navigator.standalone)if(u&&u.resolve){var l=u.resolve(void 0);n=function(){l.then(c);};}else n=function(){i.call(r,c);};else {var f=!0,d=document.createTextNode("");new o(c).observe(d,{characterData:!0}),n=function(){d.data=f=!f;};}return function(r){var i={fn:r,next:void 0};t&&(t.next=i),e||(e=i,n()),t=i;}};},function(e,t,n){var r=n(0).navigator;e.exports=r&&r.userAgent||"";},function(e,t,n){var r=n(10);e.exports=function(e,t,n){for(var i in t)n&&e[i]?e[i]=t[i]:r(e,i,t[i]);return e};},function(e,t,n){var r=n(0),i=n(2),o=n(7),s=n(9),u=n(1)("species");e.exports=function(e){var t="function"==typeof i[e]?i[e]:r[e];s&&t&&!t[u]&&o.f(t,u,{configurable:!0,get:function(){return this}});};},function(e,t,n){var r=n(1)("iterator"),i=!1;try{var o=[7][r]();o.return=function(){i=!0;},Array.from(o,function(){throw 2});}catch(e){}e.exports=function(e,t){if(!t&&!i)return !1;var n=!1;try{var o=[7],s=o[r]();s.next=function(){return {done:n=!0}},o[r]=function(){return s},e(o);}catch(e){}return n};},function(e,t,n){var r=n(6),i=n(2),o=n(0),s=n(60),u=n(63);r(r.P+r.R,"Promise",{finally:function(e){var t=s(this,i.Promise||o.Promise),n="function"==typeof e;return this.then(n?function(n){return u(t,e()).then(function(){return n})}:e,n?function(n){return u(t,e()).then(function(){throw n})}:e)}});},function(e,t,n){var r=n(6),i=n(43),o=n(62);r(r.S,"Promise",{try:function(e){var t=i.f(this),n=o(e);return (n.e?t.reject:t.resolve)(n.v),t.promise}});},function(e,t,n){t.__esModule=!0;var r,i=n(45),o=(r=i)&&r.__esModule?r:{default:r};t.default=function(e,t,n){return t in e?(0, o.default)(e,t,{value:n,enumerable:!0,configurable:!0,writable:!0}):e[t]=n,e};},function(e,t,n){Object.defineProperty(t,"__esModule",{value:!0});var r=p(n(41)),i=p(n(42)),o=p(n(4)),s=p(n(5)),u=p(n(16)),a=p(n(20)),c=p(n(120)),l=p(n(26)),f=n(130),d=n(14);function p(e){return e&&e.__esModule?e:{default:e}}var h=function(e){function t(){var e=arguments.length>0&&void 0!==arguments[0]?arguments[0]:{};(0, o.default)(this,t);var n=(0, u.default)(this,(t.__proto__||Object.getPrototypeOf(t)).call(this));return n._init(e),n._websocket=null,n}return (0, a.default)(t,e),(0, s.default)(t,[{key:"_init",value:function(e){var t=e.status,n=e.logger,r=void 0===n?f.pureLogger:n;this._mainStatus=t,this.logger=r,this._initStatus();}},{key:"_initStatus",value:function(){var e=this;this._status||(this._status={}),Object.keys(this._status).forEach(function(t){delete e._status[t];}),Object.assign(this._status,{needReconnect:!1,reconnectTimer:null,currentOptions:null,reconnectCount:0,reconnectMaxNum:8,destroy:!1});}},{key:"_destroy",value:function(){return this._resetReconnectStatus(!0),this.stopSignal()}},{key:"_resetReconnectStatus",value:function(){var e=arguments.length>0&&void 0!==arguments[0]&&arguments[0];clearTimeout(this._status.reconnectTimer),Object.assign(this._status,{needReconnect:!1,reconnectCount:0,reconnectTimer:null,destroy:e});}},{key:"_resetWhenClose",value:function(){this._resetReconnectStatus(),this._unbindEvent(),this._websocket=null,this._initStatus();}},{key:"_bindEvent",value:function(){var e=this;this._websocket?(this._websocket.on("open",this._onOpen.bind(this)),this._websocket.on("error",this._onError.bind(this)),this._websocket.on("close",this._onClose.bind(this)),this._websocket.on("hangup",this._onHangup.bind(this)),this._websocket.on("syncDone",this._onSyncDone.bind(this)),this._websocket.on("clientLeave",this._onClientLeave.bind(this)),this._websocket.on("clientJoin",this._onClientJoin.bind(this)),this._websocket.on("clientUpdate",this._onClientUpdate.bind(this)),this._websocket.on("clientMute",this._onClientMute.bind(this)),this._websocket.on("liveRoomClose",this._onLiveRoomClose.bind(this)),this._websocket.on("kicked",this._onKicked.bind(this)),this._websocket.on("roomRefused",this._onRoomRefused.bind(this)),this._websocket.on("clientPublished",this._onClientPublished.bind(this)),this._websocket.on("changeRoled",this._onChangeRoled.bind(this)),this._websocket.on("abilityNotSupport",this._onAbilityNotSupport.bind(this)),this._websocket.on("clientMediaStatus",this._onClientMediaStatus.bind(this)),this._websocket.on("rtmpTaskStatus",this._onRtmpTaskStatus.bind(this)),this._websocket.on("sendCommandOverTime",this._onSendCommandOverTime.bind(this)),this._websocket.on("heartbeatOverTime",function(t){e.logger.log("WSController::heartbeatOverTime",t),e.stopSignal(!0);})):this.logger.warn("WSController::_bindEvent: _websocket为空！");}},{key:"_unbindEvent",value:function(){this._websocket&&(this._websocket.off("open"),this._websocket.off("error"),this._websocket.off("close"),this._websocket.off("hangup"),this._websocket.off("syncDone"),this._websocket.off("clientLeave"),this._websocket.off("clientJoin"),this._websocket.off("clientUpdate"),this._websocket.off("clientMute"),this._websocket.off("liveRoomClose"),this._websocket.off("kicked"),this._websocket.off("roomRefused"),this._websocket.off("clientPublished"),this._websocket.off("changeRoled"),this._websocket.off("abilityNotSupport"),this._websocket.off("sendCommandOverTime"),this._websocket.off("heartbeatOverTime"));}},{key:"_onOpen",value:function(e){}},{key:"_onError",value:function(e){e&&"登录失败"==e.reason?(this.logger.log("[socket error] 登录失败"),this._resetReconnectStatus(),this.emit("loginFailed",e)):this._status.reconnectTimer||(this.logger.log("[socket error] 开始网络重连"),this.stopSignal(!0)),this._status.needReconnect||(e.connectCount=this._status.reconnectCount,this.logger.log("[socket error] 反馈Error"),this.emit("error",e));}},{key:"_onClose",value:function(){var e=this;if(this._status.needReconnect)this._unbindEvent(),this._websocket=null,this.logger.log("[重连] 当前重连的次数: "+this._status.reconnectCount,(new Date).toString()),this.emit("willreconnect",{count:this._status.reconnectCount}),this._status.reconnectTimer&&clearTimeout(this._status.reconnectTimer),this._status.reconnectTimer=setTimeout(function(){e._status.reconnectTimer=null,e.logger.log("[重连] startSignal()"),e.startSignal().then(function(t){e.logger.log("[重连] 成功，反馈reconnected事件"),e.emit("reconnected");}).catch(function(t){e.logger.warn("[重连] 重连失败: ",t.reason),t&&"ws connect timmout"===t.reason&&(e.logger.log("[重连] ws超时时间内没有响应，开始重建"),e._onClose());});},7e3);else {this.logger.log("主动触发的destroy");var t=this._status.destroy;this._resetWhenClose(),t?this.emit("disconnect"):(this.emit("close"),this.logger.log("wsController::onclose: close need not reconnect"));}}},{key:"_onHangup",value:function(){return this.setEndSessionTime(),this._resetReconnectStatus(!0),this.stopSignal()}},{key:"_onSyncDone",value:function(e){e.connectCount=this._status.reconnectCount,this._status.reconnectCount=0,this.emit("syncDone",e);}},{key:"_onClientLeave",value:function(e){if(this._mainStatus.sessionMode===d.SESSION_MODE.P2P)return this.emit("_invokeHangup",{channelId:e.cid,timetag:+new Date,account:e.accid}),void this.logger.log("wsController::onClientLeave: _invokeHangup");var t=Object.assign({},e);this.emit("clientLeave",t);}},{key:"_onClientJoin",value:function(e){var t=Object.assign({},e);this.emit("clientJoin",t);}},{key:"_onClientUpdate",value:function(e){var t=Object.assign({},e.body);this.emit("clientUpdate",t);}},{key:"_onClientMute",value:function(e){Object.assign({},e);this.emit("clientMute",e);}},{key:"_onLiveRoomClose",value:function(e){this.emit("liveRoomClose",e);}},{key:"_onKicked",value:function(e){this.emit("kicked",e);}},{key:"_onRoomRefused",value:function(e){this.emit("roomRefused",e);}},{key:"_onSendCommandOverTime",value:function(){this.emit("sendCommandOverTime");}},{key:"_onClientPublished",value:function(e){var t=Object.assign({},e.body);this.emit("clientPublished",t);}},{key:"_onChangeRoled",value:function(e){var t=Object.assign({},e.body);this.emit("changeRoled",t);}},{key:"_onAbilityNotSupport",value:function(e){var t=Object.assign({},e.body);this.emit("abilityNotSupport",t);}},{key:"_onClientMediaStatus",value:function(e){var t=Object.assign({},e.body);this.emit("clientMediaStatus",t);}},{key:"_onRtmpTaskStatus",value:function(e){var t=Object.assign({},e.body);this.emit("rtmpTaskStatus",t);}},{key:"joinChannel",value:function(e){return this.setStartSessionTime(),e.logger=this.logger,e.mainStatus=this._mainStatus,this._status.currentOptions=e,this.startSignal(e)}},{key:"leaveChannel",value:function(){return this.logger.log("[leave] leaveChannel() 主动离开房间"),this.setEndSessionTime(),this._resetReconnectStatus(!0),this.stopSignal()}},{key:"startSignal",value:function(e){if(e||(e=this._status.currentOptions),this.logger.log("[重连] startSignal() 当前重连次数： "+this._status.reconnectCount+", 最大重连次数: "+this._status.reconnectMaxNum),!(this._status.reconnectCount<=this._status.reconnectMaxNum)){this._resetReconnectStatus(!0),this.logger.warn("[重连] startSignal() 已经达到最大重连次数，直接退出");return this.emit("reconnectFailed",{message:"number of connections exceeded"}),Promise.reject(d.CONSTANT_ERROR.reconnectFail)}if(!this._websocket)return this._status.needReconnect=!0,this._status.reconnectCount++,this._websocket=new c.default(e),this._bindEvent(),this.logger.log("[重连] startSignal() 开始连接服务器"),this._websocket.login();this.logger.log("[重连] startSignal() 已经连接成功");}},{key:"stopSignal",value:function(){var e=arguments.length>0&&void 0!==arguments[0]&&arguments[0];return this.logger.log("[leave] stopSignal() 是否是重连 isConnect: ",e),this._websocket&&!e?(this.logger.log("[leave] stopSignal() 开始注销"),this._websocket.logout()):(this._onClose(),Promise.resolve())}},{key:"publish",value:function(){var e=(0, i.default)(r.default.mark(function e(t){return r.default.wrap(function(e){for(;;)switch(e.prev=e.next){case 0:return e.abrupt("return",this._websocket.publish(t));case 1:case"end":return e.stop()}},e,this)}));return function(t){return e.apply(this,arguments)}}()},{key:"unpublish",value:function(){var e=(0, i.default)(r.default.mark(function e(t){return r.default.wrap(function(e){for(;;)switch(e.prev=e.next){case 0:return e.abrupt("return",this._websocket.unpublish(t));case 1:case"end":return e.stop()}},e,this)}));return function(t){return e.apply(this,arguments)}}()},{key:"subscribe",value:function(){var e=(0, i.default)(r.default.mark(function e(t,n,i){return r.default.wrap(function(e){for(;;)switch(e.prev=e.next){case 0:return e.abrupt("return",this._websocket.subscribe(t,n));case 1:case"end":return e.stop()}},e,this)}));return function(t,n,r){return e.apply(this,arguments)}}()},{key:"unsubscribe",value:function(){var e=(0, i.default)(r.default.mark(function e(t,n,i){return r.default.wrap(function(e){for(;;)switch(e.prev=e.next){case 0:return e.abrupt("return",this._websocket.unsubscribe(t,n));case 1:case"end":return e.stop()}},e,this)}));return function(t,n,r){return e.apply(this,arguments)}}()},{key:"mute",value:function(){var e=(0, i.default)(r.default.mark(function e(t,n){return r.default.wrap(function(e){for(;;)switch(e.prev=e.next){case 0:return e.abrupt("return",this._websocket.mute(t,n));case 1:case"end":return e.stop()}},e,this)}));return function(t,n){return e.apply(this,arguments)}}()},{key:"unmute",value:function(){var e=(0, i.default)(r.default.mark(function e(t,n){return r.default.wrap(function(e){for(;;)switch(e.prev=e.next){case 0:return e.abrupt("return",this._websocket.unmute(t,n));case 1:case"end":return e.stop()}},e,this)}));return function(t,n){return e.apply(this,arguments)}}()},{key:"changeRole",value:function(){var e=(0, i.default)(r.default.mark(function e(t){return r.default.wrap(function(e){for(;;)switch(e.prev=e.next){case 0:return e.abrupt("return",this._websocket.changeRole(t));case 1:case"end":return e.stop()}},e,this)}));return function(t){return e.apply(this,arguments)}}()},{key:"updateAudioChangeMode",value:function(){var e=(0, i.default)(r.default.mark(function e(t){return r.default.wrap(function(e){for(;;)switch(e.prev=e.next){case 0:return this._status.currentOptions.audioChangeMode=t,e.abrupt("return",this._websocket.updateAudioChangeMode(t));case 2:case"end":return e.stop()}},e,this)}));return function(t){return e.apply(this,arguments)}}()},{key:"updateVoiceBeautifierPreset",value:function(){var e=(0, i.default)(r.default.mark(function e(t){return r.default.wrap(function(e){for(;;)switch(e.prev=e.next){case 0:return this._status.currentOptions.audioBeautyType=t,e.abrupt("return",this._websocket.updateVoiceBeautifierPreset(t));case 2:case"end":return e.stop()}},e,this)}));return function(t){return e.apply(this,arguments)}}()},{key:"updateAudioEffectPreset",value:function(){var e=(0, i.default)(r.default.mark(function e(t){return r.default.wrap(function(e){for(;;)switch(e.prev=e.next){case 0:return this._status.currentOptions.audioChangeType=t,e.abrupt("return",this._websocket.updateAudioEffectPreset(t));case 2:case"end":return e.stop()}},e,this)}));return function(t){return e.apply(this,arguments)}}()},{key:"updateLocalVoicePitch",value:function(){var e=(0, i.default)(r.default.mark(function e(t){return r.default.wrap(function(e){for(;;)switch(e.prev=e.next){case 0:return this._status.currentOptions.audioLocalPitch=t,e.abrupt("return",this._websocket.updateLocalVoicePitch(t));case 2:case"end":return e.stop()}},e,this)}));return function(t){return e.apply(this,arguments)}}()},{key:"updateLocalVoiceEqualization",value:function(){var e=(0, i.default)(r.default.mark(function e(t){return r.default.wrap(function(e){for(;;)switch(e.prev=e.next){case 0:return e.abrupt("return",this._websocket.updateLocalVoiceEqualization(t));case 1:case"end":return e.stop()}},e,this)}));return function(t){return e.apply(this,arguments)}}()},{key:"switchMode",value:function(e){return this._websocket.updatePushMode(e)}},{key:"setStartSessionTime",value:function(){this.emit("sessionStart");}},{key:"setEndSessionTime",value:function(){this.emit("sessionEnd");}}]),t}(l.default);t.default=h,e.exports=t.default;},function(e,t,n){Object.defineProperty(t,"__esModule",{value:!0});var r=p(n(4)),i=p(n(5)),o=p(n(16)),s=p(n(20)),u=p(n(26)),a=(p(n(27)),n(121)),c=n(122),l=n(123),f=n(14),d=n(129);function p(e){return e&&e.__esModule?e:{default:e}}var h=function(e){function t(){var e=arguments.length>0&&void 0!==arguments[0]?arguments[0]:{};(0, r.default)(this,t);var n=(0, o.default)(this,(t.__proto__||Object.getPrototypeOf(t)).call(this));return n._reset(),n.$options=e,n._mainStatus=e.mainStatus,n.logger=e.logger,n._resetStatus(),Object.keys(n._status).forEach(function(t){var r=e[t];null!=r&&(n._status[t]=r);}),n._status.edgeAddr=e.edgeAddr||"59.111.239.249:31101",n}return (0, s.default)(t,e),(0, i.default)(t,[{key:"_resetStatus",value:function(){if(this._status&&(clearInterval(this._status.heartbeatTimer),clearTimeout(this._status.heartbeatOverTimer),this._status.sendCommandTimerMap&&0!==Object.keys(this._status.sendCommandTimerMap).length))for(var e in this._status.sendCommandTimerMap)clearTimeout(this._status.sendCommandTimerMap[e]);this._status={dualAudio:0,uid:"",cid:"",accid:"",token:"",address:[],webrtc:1,mode:0,scene:1,usertype:3,liveEnable:0,rtmpRecord:0,rtmpUrl:"",splitMode:"",recordAudio:0,recordVideo:0,recordType:0,isHostSpeaker:0,role:0,seq:1,cmdTasksMap:{},heartbeatTimer:null,heartbeatOverTimer:null,sendCommandTimerMap:{},layout:"",socketStatus:"CLOSED",checkP2PUserTimer:null,edgeAddr:"",audioChangeMode:0,audioLocalPitch:"1",audioChangeType:0,audioBeautyType:0},this._resolve=null,this._reject=null,this._loginTimer&&clearTimeout(this._loginTimer),this._loginTimer=null;}},{key:"_reset",value:function(){this.$options={},this._resetStatus(),this._wsLink=null;}},{key:"login",value:function(){var e=this;return new Promise(function(t,n){e.logger.log("[websocket] login() 建立长链接, url: ",e._status.address),e._reject=n,"qq"==e._mainStatus.runtimeEnvironment?e._wsLink=qq.connectSocket({url:e._status.address,fail:function(t){e.logger.error("[websocket] login() 动作执行失败： ",f.CONSTANT_ERROR.connectSocketFail.desc),e._status.socketStatus="CLOSED",n(Object.assign(f.CONSTANT_ERROR.connectSocketFail,{reason:f.CONSTANT_ERROR.connectSocketFail.desc}));},success:function(n){e._status.socketStatus="OPENING",e._resolve=t;},complete:function(e){}}):"wechat"===e._mainStatus.runtimeEnvironment?e._wsLink=wx.connectSocket({url:e._status.address,fail:function(t){e.logger.error("[websocket] login() 动作执行失败： ",f.CONSTANT_ERROR.connectSocketFail.desc),e._status.socketStatus="CLOSED",n(Object.assign(f.CONSTANT_ERROR.connectSocketFail,{reason:f.CONSTANT_ERROR.connectSocketFail.desc}));},success:function(n){e._status.socketStatus="OPENING",e._resolve=t;},complete:function(e){}}):n(Object.assign(f.CONSTANT_ERROR.invalidOperation,{reason:"不支持的平台"})),e._bindWXSocketEvent(),e._loginTimer&&clearTimeout(e._loginTimer),e._loginTimer=setTimeout(function(){e._reject&&(e.closeSocket(),e._reject(Object.assign(f.CONSTANT_ERROR.connectSocketFail,{reason:"ws connect timmout"})));},5e3);})}},{key:"logout",value:function(){this.logger.log("[websocket] logout() socketStatus "+this._status.socketStatus),clearInterval(this._status.heartbeatTimer);var e={uid:this._status.uid,cid:this._status.cid,statistic:{},seq:this._status.seq++};switch(this.sendCmd("logout",e),this._status.socketStatus){case"OPENING":case"OPEN":case"LOGIN":case"CLOSING":return this.closeSocket();case"CLOSED":this.emit("close");}return Promise.resolve()}},{key:"closeSocket",value:function(){var e=this;return new Promise(function(t,n){e.logger.log("[websocket] closeSocket() 主动清除小程序ws连接"),clearInterval(e._status.heartbeatTimer),clearTimeout(e._status.heartbeatOverTimer),e._wsLink.onOpen=null,e._wsLink.onOpen=null,e._wsLink.onOpen=null,e._wsLink.onMessage=null,e._wsLink.close({code:1e3,reason:"ws::user force close websocket",success:function(t){e._status.socketStatus="CLOSING",e.logger.log("[websocket] closeSocket() closed success");},fail:function(t){e._status.socketStatus="CLOSING",e.logger.log("[websocket] closeSocket() closed fail");},complete:function(){e.logger.log("[websocket] closeSocket() closed complete"),e.emit("close"),t();}});})}},{key:"publish",value:function(e){var t=this;return new Promise(function(n,r){t.sendCmd("publish",{mediaType:e,uid:t._status.uid,cid:t._status.cid,status:"open"}).then(function(e){200===e.code?n():r(e);});})}},{key:"unpublish",value:function(e){var t=this;return new Promise(function(n,r){t.sendCmd("unpublish",{mediaType:e,uid:t._status.uid,cid:t._status.cid,status:"close"}).then(function(e){200===e.code?n():r(e);});})}},{key:"subscribe",value:function(e,t){var n=this;return new Promise(function(r,i){n.sendCmd("subscribe",{mediaType:t,uid:n._status.uid,srcUid:e,cid:n._status.cid,sub:!0}).then(function(e){n.logger.log("订阅返回结果：",JSON.stringify(e,null," ")),200===e.code?r():i(e);});})}},{key:"unsubscribe",value:function(e,t){var n=this;return new Promise(function(r,i){n.sendCmd("unsubscribe",{mediaType:t,uid:n._status.uid,srcUid:e,cid:n._status.cid,sub:!1}).then(function(e){200===e.code?r():i(e);});})}},{key:"setDualAudio",value:function(e,t){var n=this;return new Promise(function(r,i){n.sendCmd("dualAudio",{uid:n._status.uid,srcUid:e,cid:n._status.cid,dualAudio:t}).then(function(e){n.logger.log("dualAudio返回结果：",JSON.stringify(e,null," ")),200===e.code?r():i(e);});})}},{key:"mute",value:function(e,t){var n=this;return new Promise(function(r,i){n.sendCmd("mute",{uid:e||n._status.uid,mediaType:t,cid:n._status.cid,mute:!0}).then(function(e){200===e.code?r():i(e);});})}},{key:"unmute",value:function(e,t){var n=this;return new Promise(function(r,i){n.sendCmd("unmute",{uid:e||n._status.uid,mediaType:t,cid:n._status.cid,mute:!1}).then(function(e){200===e.code?r():i(e);});})}},{key:"changeRole",value:function(e){var t=this;return new Promise(function(n,r){t.sendCmd("changeRole",{uid:t._status.uid,cid:t._status.cid,role:e}).then(function(e){200===e.code?n():r(e);});})}},{key:"updateAudioChangeMode",value:function(e){var t=this;return new Promise(function(n,r){t.sendCmd("updateAudioChangeMode",{uid:t._status.uid,cid:t._status.cid,mode:e}).then(function(e){200===e.code?n():r(e);});})}},{key:"updateVoiceBeautifierPreset",value:function(e){var t=this;return new Promise(function(n,r){t.sendCmd("updateVoiceBeautifierPreset",{uid:t._status.uid,cid:t._status.cid,type:e}).then(function(e){200===e.code?n():r(e);});})}},{key:"updateAudioEffectPreset",value:function(e){var t=this;return new Promise(function(n,r){t.sendCmd("updateAudioEffectPreset",{uid:t._status.uid,cid:t._status.cid,type:e}).then(function(e){200===e.code?n():r(e);});})}},{key:"updateLocalVoicePitch",value:function(e){var t=this;return new Promise(function(n,r){t.sendCmd("updateLocalVoicePitch",{uid:t._status.uid,cid:t._status.cid,pitch:e}).then(function(e){200===e.code?n():r(e);});})}},{key:"updateLocalVoiceEqualization",value:function(e){var t=this;return new Promise(function(n,r){t.sendCmd("updateLocalVoiceEqualization",{uid:t._status.uid,cid:t._status.cid,equa:e}).then(function(e){200===e.code?n():r(e);});})}},{key:"updatePushMode",value:function(e){var t=this;return this._status.mode=e,new Promise(function(e,n){t.sendCmd("updatePushMode",t._status).then(function(t){200===t.code?e():n(t);});})}},{key:"startHeartbeat",value:function(){var e=this;this._status.heartbeatTimer=setInterval(function(){if(!e._status.heartbeatOverTimer){var t=Date.now();e._status.heartbeatOverTimer=setTimeout(function(){e.logger.log("[websocket] 心跳发送超时: ",(new Date).toString()),e.emit("heartbeatOverTime",{lastTime:t});},d.Config.heartbeatOverTime);}return e.sendCmd("heartbeat",e._status)},d.Config.heartbeatInterval);}},{key:"getUploadUserList",value:function(){var e=this;return new Promise(function(t,n){e.sendCmd("getUploadUserList",e._status).then(function(e){200===e.code?t(e):n(e);});})}},{key:"_bindWXSocketEvent",value:function(){var e=this;this._wsLink.onOpen(function(t){e._status.socketStatus="OPEN",e._status.newprotocol=2,e.emit("open",f.CONSTANT_SOCKET.connectSocketSuccess),e.logger.log("[websocket onOpen] ws连接成功，准备login请求"),e.sendCmd("login",e._status).then(function(t){e.logger.log("[websocket onOpen] login成功"),e._status.socketStatus="LOGIN",e.startHeartbeat(),e.emit("syncDone",t),e._resolve&&(e.logger.log("[websocket onOpen] join流程完成, 反馈resolve()"),e._resolve(),e._resolve=e._reject=null,e._loginTimer&&clearTimeout(e._loginTimer),e._loginTimer=null);}).catch(function(t){e.emit("error",{code:t.code,reason:"登录失败"}),e._reject&&e._reject(Object.assign(f.CONSTANT_ERROR.connectSocketFail,{code:t.code,reason:"登录失败"}));});}),this._wsLink.onError(function(t){e.logger.log("[websocket onError] event: ",t),e.emit("error",t);}),this._wsLink.onClose(function(t){e._status.socketStatus="CLOSED",e.logger.log("[websocket onClose] event: ",t),e.emit("close",t),e._reset();}),this._wsLink.onMessage(function(t){var n=t.data;if(n=(0, l.parsePacket)(n)){if("onHeartbeat"!==n.cmd&&e.logger.log("[websocket onMessage] data: ",n),n.seq){var r=e._status.cmdTasksMap[n.seq];r&&(delete e._status.cmdTasksMap[n.seq],r.resolve(n.body));}e[n.cmd]&&e[n.cmd](n),0!==Object.keys(e._status.sendCommandTimerMap).length&&(clearTimeout(e._status.sendCommandTimerMap[n.seq]),delete e._status.sendCommandTimerMap[n.seq]);}else e.logger.log("[websocket onMessage] unknown data");});}},{key:"sendCmd",value:function(e,t){var n=this;if("heartbeat"===e){var r=(0, l.genPacket)(e,t,this._status.seq++,this._status.isHostSpeaker,this._mainStatus.isBigNumberOfLocalUid);return this._wsLink.send({data:r}),Promise.resolve()}var i=setTimeout(function(){n.logger.log("[websocket] sendCmd() 信令发送超时: ",e),n.emit("sendCommandOverTime",{cmd:e});},d.Config.sendCommandOverTime);return this._status.sendCommandTimerMap[this._status.seq]=i,new Promise(function(r,i){"logout"===e&&setTimeout(function(){r();},300),n._status.cmdTasksMap[n._status.seq]={resolve:r,reject:i};var o=(0, l.genPacket)(e,t,n._status.seq++);n.logger.log("[websocket] sendCmd() data: ",o);try{n._wsLink.send({data:o});}catch(e){return n.logger.error("小程序ws::信令发送失败:",e),Promise.reject(e)}})}}]),t}(u.default);(0, a.apiMixin)(h),(0, c.messageMixin)(h),t.default=h,e.exports=t.default;},function(e,t,n){Object.defineProperty(t,"__esModule",{value:!0}),t.apiMixin=function(e){e.prototype;};},function(e,t,n){Object.defineProperty(t,"__esModule",{value:!0}),t.messageMixin=function(e){var t=e.prototype;t.onClientLeave=function(e){this.emit("clientLeave",e.body);},t.onClientJoin=function(e){this.emit("clientJoin",e.body);},t.onClientMute=function(e){this.emit("clientMute",e.body);},t.onClientUpdate=function(e){this.emit("clientUpdate",e);},t.onUpdatePushMode=function(e){this.emit("updatePushMode",e);},t.onLiveRoomClose=function(e){this.emit("liveRoomClose",e);},t.onKicked=function(e){this.emit("kicked",e);},t.onRoomRefused=function(e){this.emit("roomRefused",e);},t.clientPublished=function(e){this.emit("clientPublished",e);},t.changeRoled=function(e){this.emit("changeRoled",e);},t.abilityNotSupport=function(e){this.emit("abilityNotSupport",e);},t.clientMediaStatus=function(e){this.emit("clientMediaStatus",e);},t.rtmpTaskStatus=function(e){this.emit("rtmpTaskStatus",e);},t.onHeartbeat=function(e){clearTimeout(this._status.heartbeatOverTimer),this._status.heartbeatOverTimer=null;};};},function(e,t,n){Object.defineProperty(t,"__esModule",{value:!0}),t.genPacket=function(e,t,n){var o=i[e];if(o){var s={cmd:o.cmd,body:{},seq:n},u=Object.assign({},s),a=o.body;return a.forEach(function(e){(t[e.key]||0===t[e.key])&&(u.body[e.key]=t[e.key]);}),r.stringify(u)}},t.parsePacket=function(e){var t=r.parse(e);if(t){var n=o[t.cmd];if(n)return t.cmd=n.cmd,t;console.log("未知消息: ",e);}else console.log("协议解析失败: ",e);return null};var r=n(124);var i={login:{cmd:0,body:[{key:"accid",type:"String"},{key:"uid",type:"Number"},{key:"cid",type:"String"},{key:"accid",type:"Number"},{key:"token",type:"String"},{key:"mode",type:"Number"},{key:"scene",type:"Number"},{key:"usertype",type:"Number"},{key:"liveEnable",type:"Number"},{key:"webrtc",type:"Number"},{key:"recordAudio",type:"Number"},{key:"recordVideo",type:"Number"},{key:"rtmpRecord",type:"Number"},{key:"rtmpUrl",type:"String"},{key:"splitMode",type:"Number"},{key:"layout",type:"Boolean"},{key:"recordType",type:"String"},{key:"role",type:"Number"},{key:"isHostSpeaker",type:"Number"},{key:"edgeAddr",type:"String"},{key:"newprotocol",type:"Number"},{key:"audioChangeMode",type:"Number"},{key:"audioLocalPitch",type:"String"},{key:"audioChangeType",type:"Number"},{key:"audioBeautyType",type:"Number"}]},heartbeat:{cmd:2,body:[{key:"uid",type:"Number"},{key:"cid",type:"String"},{key:"statistic",type:"Object"}]},logout:{cmd:4,body:[{key:"uid",type:"Number"},{key:"cid",type:"String"},{key:"statistic",type:"Object"}]},publish:{cmd:10,body:[{key:"uid",type:"Number"},{key:"cid",type:"String"},{key:"mediaType",type:"String"},{key:"status",type:"String"}]},unpublish:{cmd:10,body:[{key:"uid",type:"Number"},{key:"cid",type:"String"},{key:"mediaType",type:"String"},{key:"status",type:"String"}]},subscribe:{cmd:16,body:[{key:"uid",type:"Number"},{key:"cid",type:"String"},{key:"srcUid",type:"String"},{key:"mediaType",type:"String"},{key:"sub",type:"Boolean"}]},unsubscribe:{cmd:16,body:[{key:"uid",type:"Number"},{key:"cid",type:"String"},{key:"srcUid",type:"String"},{key:"mediaType",type:"String"},{key:"sub",type:"Boolean"}]},dualAudio:{cmd:17,body:[{key:"uid",type:"Number"},{key:"cid",type:"String"},{key:"srcUid",type:"String"},{key:"dualAudio",type:"Number"}]},mute:{cmd:11,body:[{key:"uid",type:"Number"},{key:"cid",type:"String"},{key:"mediaType",type:"String"},{key:"mute",type:"Boolean"}]},unmute:{cmd:11,body:[{key:"uid",type:"Number"},{key:"cid",type:"String"},{key:"mediaType",type:"String"},{key:"mute",type:"Boolean"}]},changeRole:{cmd:12,body:[{key:"uid",type:"Number"},{key:"cid",type:"String"},{key:"role",type:"Number"}]},getUploadUserList:{cmd:5,body:[{key:"uid",type:"Number"},{key:"cid",type:"Number"}]},updatePushMode:{cmd:7,body:[{key:"uid",type:"Number"},{key:"cid",type:"Number"},{key:"mode",type:"Number"}]},updateAudioChangeMode:{cmd:40,body:[{key:"uid",type:"Number"},{key:"cid",type:"Number"},{key:"mode",type:"Number"}]},updateLocalVoicePitch:{cmd:41,body:[{key:"uid",type:"Number"},{key:"cid",type:"Number"},{key:"pitch",type:"String"}]},updateAudioEffectPreset:{cmd:42,body:[{key:"uid",type:"Number"},{key:"cid",type:"Number"},{key:"type",type:"Number"}]},updateVoiceBeautifierPreset:{cmd:43,body:[{key:"uid",type:"Number"},{key:"cid",type:"Number"},{key:"type",type:"Number"}]},updateLocalVoiceEqualization:{cmd:44,body:[{key:"uid",type:"Number"},{key:"cid",type:"Number"},{key:"equa",type:"String"}]}},o={1:{cmd:"onLogin",body:[{key:"code"},{key:"errmsg"},{key:"userlist"}]},3:{cmd:"onHeartbeat",body:[{key:"code"},{key:"errmsg"},{key:"userlist"}]},6:{cmd:"onUploadUserList",body:[{key:"code"},{key:"errmsg"},{key:"userlist"}]},8:{cmd:"onUpdatePushMode",body:[{key:"code"},{key:"errmsg"}]},9:{cmd:"onLogout",body:[{key:"code"}]},14:{cmd:"onPublishOrUnpublish",body:[{key:"code"},{key:"errmsg"},{key:"cid"},{key:"uid"}]},15:{cmd:"onClientMute",body:[{key:"mediaType"},{key:"mute"},{key:"cid"},{key:"uid"}]},20:{cmd:"onClientJoin",body:[{key:"uid"},{key:"accid"},{key:"cid"},{key:"url"},{key:"screenUrl"},{key:"mode"},{key:"role"}]},21:{cmd:"onClientLeave",body:[{key:"uid"},{key:"accid"},{key:"cid"}]},22:{cmd:"onClientUpdate",body:[{key:"uid"},{key:"accid"},{key:"cid"},{key:"mode"}]},23:{cmd:"onLiveRoomClose",body:[{key:"cid"},{key:"reason"}]},24:{cmd:"onKicked",body:[{key:"cid"},{key:"reason"}]},25:{cmd:"onRoomRefused",body:[{key:"cid"},{key:"reason"}]},26:{cmd:"clientPublished",body:[{key:"uid"},{key:"accid"},{key:"cid"},{key:"mediaType"},{key:"status"},{key:"media_status"}]},27:{cmd:"changeRoled",body:[{key:"uid"},{key:"accid"},{key:"cid"},{key:"role"}]},28:{cmd:"abilityNotSupport",body:[{key:"uid"},{key:"accid"},{key:"cid"},{key:"code"},{key:"msg"}]},30:{cmd:"clientMediaStatus",body:[{key:"uid"},{key:"accid"},{key:"cid"},{key:"url"},{key:"mediaType"},{key:"status"}]},31:{cmd:"rtmpTaskStatus",body:[{key:"uid"},{key:"accid"},{key:"hotsUid"},{key:"cid"},{key:"streamUrl"},{key:"taskId"},{key:"code"},{key:"msg"}]}};},function(e,t,n){var r=n(125).stringify,i=n(126);e.exports=function(e){return {parse:i(e),stringify:r}},e.exports.parse=i(),e.exports.stringify=r;},function(e,t,n){var r=n(28),i=e.exports;!function(){var e,t,n,o=/[\\\"\x00-\x1f\x7f-\x9f\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,s={"\b":"\\b","\t":"\\t","\n":"\\n","\f":"\\f","\r":"\\r",'"':'\\"',"\\":"\\\\"};function u(e){return o.lastIndex=0,o.test(e)?'"'+e.replace(o,function(e){var t=s[e];return "string"==typeof t?t:"\\u"+("0000"+e.charCodeAt(0).toString(16)).slice(-4)})+'"':'"'+e+'"'}"function"!=typeof i.stringify&&(i.stringify=function(i,o,s){var a;if(e="",t="","number"==typeof s)for(a=0;a<s;a+=1)t+=" ";else "string"==typeof s&&(t=s);if(n=o,o&&"function"!=typeof o&&("object"!=typeof o||"number"!=typeof o.length))throw new Error("JSON.stringify");return function i(o,s){var a,c,l,f,d,p=e,h=s[o],g=null!=h&&(h instanceof r||r.isBigNumber(h));switch(h&&"object"==typeof h&&"function"==typeof h.toJSON&&(h=h.toJSON(o)),"function"==typeof n&&(h=n.call(s,o,h)),typeof h){case"string":return g?h:u(h);case"number":return isFinite(h)?String(h):"null";case"boolean":case"null":case"bigint":return String(h);case"object":if(!h)return "null";if(e+=t,d=[],"[object Array]"===Object.prototype.toString.apply(h)){for(f=h.length,a=0;a<f;a+=1)d[a]=i(a,h)||"null";return l=0===d.length?"[]":e?"[\n"+e+d.join(",\n"+e)+"\n"+p+"]":"["+d.join(",")+"]",e=p,l}if(n&&"object"==typeof n)for(f=n.length,a=0;a<f;a+=1)"string"==typeof n[a]&&(l=i(c=n[a],h))&&d.push(u(c)+(e?": ":":")+l);else Object.keys(h).forEach(function(t){var n=i(t,h);n&&d.push(u(t)+(e?": ":":")+n);});return l=0===d.length?"{}":e?"{\n"+e+d.join(",\n"+e)+"\n"+p+"}":"{"+d.join(",")+"}",e=p,l}}("",{"":i})});}();},function(e,t,n){var r=null;const i=/(?:_|\\u005[Ff])(?:_|\\u005[Ff])(?:p|\\u0070)(?:r|\\u0072)(?:o|\\u006[Ff])(?:t|\\u0074)(?:o|\\u006[Ff])(?:_|\\u005[Ff])(?:_|\\u005[Ff])/,o=/(?:c|\\u0063)(?:o|\\u006[Ff])(?:n|\\u006[Ee])(?:s|\\u0073)(?:t|\\u0074)(?:r|\\u0072)(?:u|\\u0075)(?:c|\\u0063)(?:t|\\u0074)(?:o|\\u006[Ff])(?:r|\\u0072)/;e.exports=function(e){var t={strict:!1,storeAsString:!1,alwaysParseAsBig:!1,useNativeBigInt:!1,protoAction:"error",constructorAction:"error"};if(null!=e){if(!0===e.strict&&(t.strict=!0),!0===e.storeAsString&&(t.storeAsString=!0),t.alwaysParseAsBig=!0===e.alwaysParseAsBig&&e.alwaysParseAsBig,t.useNativeBigInt=!0===e.useNativeBigInt&&e.useNativeBigInt,void 0!==e.constructorAction){if("error"!==e.constructorAction&&"ignore"!==e.constructorAction&&"preserve"!==e.constructorAction)throw new Error(`Incorrect value for constructorAction option, must be "error", "ignore" or undefined but passed ${e.constructorAction}`);t.constructorAction=e.constructorAction;}if(void 0!==e.protoAction){if("error"!==e.protoAction&&"ignore"!==e.protoAction&&"preserve"!==e.protoAction)throw new Error(`Incorrect value for protoAction option, must be "error", "ignore" or undefined but passed ${e.protoAction}`);t.protoAction=e.protoAction;}}var s,u,a,c,l={'"':'"',"\\":"\\","/":"/",b:"\b",f:"\f",n:"\n",r:"\r",t:"\t"},f=function(e){throw {name:"SyntaxError",message:e,at:s,text:a}},d=function(e){return e&&e!==u&&f("Expected '"+e+"' instead of '"+u+"'"),u=a.charAt(s),s+=1,u},p=function(){var e,i="";for("-"===u&&(i="-",d("-"));u>="0"&&u<="9";)i+=u,d();if("."===u)for(i+=".";d()&&u>="0"&&u<="9";)i+=u;if("e"===u||"E"===u)for(i+=u,d(),"-"!==u&&"+"!==u||(i+=u,d());u>="0"&&u<="9";)i+=u,d();if(e=+i,isFinite(e))return null==r&&(r=n(28)),i.length>15?t.storeAsString?i:t.useNativeBigInt?BigInt(i):new r(i):t.alwaysParseAsBig?t.useNativeBigInt?BigInt(e):new r(e):e;f("Bad number");},h=function(){var e,t,n,r="";if('"'===u)for(var i=s;d();){if('"'===u)return s-1>i&&(r+=a.substring(i,s-1)),d(),r;if("\\"===u){if(s-1>i&&(r+=a.substring(i,s-1)),d(),"u"===u){for(n=0,t=0;t<4&&(e=parseInt(d(),16),isFinite(e));t+=1)n=16*n+e;r+=String.fromCharCode(n);}else {if("string"!=typeof l[u])break;r+=l[u];}i=s;}}f("Bad string");},g=function(){for(;u&&u<=" ";)d();};return c=function(){switch(g(),u){case"{":return function(){var e,n=Object.create(null);if("{"===u){if(d("{"),g(),"}"===u)return d("}"),n;for(;u;){if(e=h(),g(),d(":"),!0===t.strict&&Object.hasOwnProperty.call(n,e)&&f('Duplicate key "'+e+'"'),!0===i.test(e)?"error"===t.protoAction?f("Object contains forbidden prototype property"):"ignore"===t.protoAction?c():n[e]=c():!0===o.test(e)?"error"===t.constructorAction?f("Object contains forbidden constructor property"):"ignore"===t.constructorAction?c():n[e]=c():n[e]=c(),g(),"}"===u)return d("}"),n;d(","),g();}}f("Bad object");}();case"[":return function(){var e=[];if("["===u){if(d("["),g(),"]"===u)return d("]"),e;for(;u;){if(e.push(c()),g(),"]"===u)return d("]"),e;d(","),g();}}f("Bad array");}();case'"':return h();case"-":return p();default:return u>="0"&&u<="9"?p():function(){switch(u){case"t":return d("t"),d("r"),d("u"),d("e"),!0;case"f":return d("f"),d("a"),d("l"),d("s"),d("e"),!1;case"n":return d("n"),d("u"),d("l"),d("l"),null}f("Unexpected '"+u+"'");}()}},function(e,t){var n;return a=e+"",s=0,u=" ",n=c(),g(),u&&f("Syntax error"),"function"==typeof t?function e(n,r){var i,o=n[r];return o&&"object"==typeof o&&Object.keys(o).forEach(function(t){void 0!==(i=e(o,t))?o[t]=i:delete o[t];}),t.call(n,r,o)}({"":n},""):n}};},function(e,t,n){Object.defineProperty(t,"__esModule",{value:!0});t.default={syntaxError:{code:-2,reason:"代码运行出现了语法错误"},invalidOperation:{code:434,reason:"非法操作"},closeNormal:{code:"0",reason:"mini: normally closed"},getChannelInfoFail:{code:"400",reason:"mini: no wechatapparray property"},connectSocketFail:{code:"401",reason:"mini: failed to connect"},reconnectFail:{code:"403",reason:"mini: maxceed reconnect times"},kicked:{code:"405",reason:"mini: kicked"},roomRefused:{code:"406",reason:"mini: roomRefused"},loginFailed:{code:"417",reason:"mini: login failed cause room destroyed"},loginFailedEncrypt:{code:"418",reason:"mini: login failed cause room no encryption"},publishFailed:{code:"420",reason:"mini: cannot find the push url"},addTasksFailed:{code:"434",reason:"mini: add task failed cause server refused"},deleteTasksFailed:{code:"435",reason:"mini: delete task failed cause server refused"},updateTasksFailed:{code:"436",reason:"mini: update task failed cause server refused"}},e.exports=t.default;},function(e,t,n){Object.defineProperty(t,"__esModule",{value:!0});t.default={connectSocketSuccess:{code:"200",desc:"wx: connectSocket: success"}},e.exports=t.default;},function(e,t,n){Object.defineProperty(t,"__esModule",{value:!0});t.Config={heartbeatInterval:3e3,heartbeatOverTime:1e4,sendCommandOverTime:1e4};},function(e,t,n){Object.defineProperty(t,"__esModule",{value:!0}),t.pureLogger=void 0;var r=o(n(4)),i=o(n(5));function o(e){return e&&e.__esModule?e:{default:e}}var s=function(){function e(t){var n=t.debug;(0, r.default)(this,e),this.debug=n;}return (0, i.default)(e,[{key:"log",value:function(e){if(this.debug){for(var t=arguments.length,n=Array(t>1?t-1:0),r=1;r<t;r++)n[r-1]=arguments[r];return console.log("%c WeAppRTC:: "+e,"color:#bada55",n)}}},{key:"warn",value:function(e){if(this.debug){for(var t=arguments.length,n=Array(t>1?t-1:0),r=1;r<t;r++)n[r-1]=arguments[r];return console.warn("%c WeAppRTC:: "+e,n)}}},{key:"error",value:function(e){if(this.debug){for(var t=arguments.length,n=Array(t>1?t-1:0),r=1;r<t;r++)n[r-1]=arguments[r];return console.error("%c WeAppRTC:: "+e,n)}}}]),e}();t.default=s;t.pureLogger={trace:function(){},debug:function(){},log:function(){},warn:function(){},error:function(){}};},function(e,t,n){Object.defineProperty(t,"__esModule",{value:!0});var r=a(n(4)),i=a(n(5)),o=a(n(16)),s=a(n(20)),u=a(n(26));function a(e){return e&&e.__esModule?e:{default:e}}var c=n(44).version,l=function(e){function t(){(0, r.default)(this,t);var e=(0, o.default)(this,(t.__proto__||Object.getPrototypeOf(t)).call(this));return e._statisticsServer="",e._initStatistics(),e}return (0, s.default)(t,e),(0, i.default)(t,[{key:"_initStatistics",value:function(){this._statistics={ver:1,time:null,sdk_ver:c||"v4.0.0",platform:"mini",uid:null,cid:null,appkey:null,P2P:{value:0},meeting:{value:0},always_keep_calling:{value:0},miniapp_mode:null};}},{key:"updateStatisticsServer",value:function(e){this._statisticsServer=e;}},{key:"updateStatistics",value:function(e){Object.assign(this._statistics,e),this.sendStatistics();}},{key:"sendStatistics",value:function(){var e=this;Object.assign(this._statistics,{time:+new Date});var t="https://statistic.live.126.net/statistic/realtime/sdkFunctioninfo";this._statisticsServer&&(t=this._statisticsServer);var n=this._statistics.platform;if(this._statistics.platform="mini","mini"===n||"wechat"===n)wx.request({url:t,method:"POST",data:this._statistics,header:{"content-type":"application/json"},complete:function(){e._initStatistics();}});else {if("qq"!==n)throw Error("DataReporter 不支持的平台");qq.request({url:t,method:"POST",data:this._statistics,header:{"content-type":"application/json"},complete:function(){e._initStatistics();}});}}}]),t}(u.default);t.default=l,e.exports=t.default;},function(e,t,n){var r="qq",i=n(133),o=n(139);function s(){var e=arguments.length>0&&void 0!==arguments[0]?arguments[0]:{};i.merge(this,{options:e,debug:!1,api:"log",style:"color:#1cb977;",log:i.emptyFunc,info:i.emptyFunc,warn:i.emptyFunc,error:i.emptyFunc}),this.prefix=e.prefix||"",this.setDebug(e.debug),e.isSavedLogs&&(this.logHelper=new o(e));}var u=s.prototype,a=["Chrome","Safari","Firefox"];u.setDebug=function(){var e=arguments.length>0&&void 0!==arguments[0]&&arguments[0],t=this;if(t.debug=e,e.style&&(t.style=e.style),t.debug&&i.exist(console)){var n=console;t.debug=function(){this.logHelper&&this.logHelper.log(arguments);var e=t.formatArgs(arguments);-1!==a.indexOf(r)&&i.isString(e[0])&&(e[0]="%c"+e[0],e.splice(1,0,t.style)),t._log("debug",e);},t.log=function(){this.logHelper&&this.logHelper.log(arguments);var e=t.formatArgs(arguments);-1!==a.indexOf(r)&&i.isString(e[0])&&(e[0]="%c"+e[0],e.splice(1,0,t.style)),t._log("log",e);},t.info=function(){this.logHelper&&this.logHelper.log(arguments);var e=t.formatArgs(arguments);-1!==a.indexOf(r)&&i.isString(e[0])&&(e[0]="%c"+e[0],e.splice(1,0,t.style)),t._log("info",e);},t.warn=function(){this.logHelper&&this.logHelper.log(arguments);var e=t.formatArgs(arguments);-1!==a.indexOf(r)&&i.isString(e[0])&&(e[0]="%c"+e[0],e.splice(1,0,t.style)),t._log("warn",e);},t.error=function(){this.logHelper&&this.logHelper.log(arguments);var e=t.formatArgs(arguments);-1!==a.indexOf(r)&&i.isString(e[0])&&(e[0]="%c"+e[0],e.splice(1,0,t.style)),t._log("error",e);},t._log=function(e,r){var o=t.options.logFunc,s=null;if(o&&(o[e]&&(s=o[e]),i.isFunction(s)))s.apply(o,r);else if(n[e])try{n[e].apply?t.chrome(e,r):t.ie(e,r);}catch(e){}},t.chrome=function(e,i){-1!==a.indexOf(r)?n[e].apply(n,i):t.ie(e,i);},t.ie=function(e,t){t.forEach(function(t){n[e](JSON.stringify(t,null,4));});};}},u.formatArgs=function(e){e=[].slice.call(e,0);var t=new Date,n="[LOG "+(c(t.getMonth()+1)+"-"+c(t.getDate())+" "+c(t.getHours())+":"+c(t.getMinutes())+":"+c(t.getSeconds())+":"+c(t.getMilliseconds(),3))+" "+this.prefix.toUpperCase()+"]  ";return i.isString(e[0])?e[0]=n+e[0]:e.splice(0,0,n),e.forEach(function(t,n){(i.isArray(t)||i.isObject(t))&&(e[n]=i.simpleClone(t));}),e};var c=function(e,t){t=t||2;for(var n=""+e;n.length<t;)n="0"+n;return n};e.exports=s;},function(e,t,n){var r,i=n(12),o=(r=i)&&r.__esModule?r:{default:r};var s=n(134),u=n(135);function a(e){"object"===(void 0===e?"undefined":(0, o.default)(e))?(this.callFunc=e.callFunc||null,this.message=e.message||"UNKNOW ERROR"):this.message=e,this.time=new Date,this.timetag=+this.time;}n(136);var c,l,f=n(137),d=f.getGlobal(),p=/\s+/;f.deduplicate=function(e){var t=[];return e.forEach(function(e){-1===t.indexOf(e)&&t.push(e);}),t},f.capFirstLetter=function(e){return e?(e=""+e).slice(0,1).toUpperCase()+e.slice(1):""},f.guid=(c=function(){return (65536*(1+Math.random())|0).toString(16).substring(1)},function(){return c()+c()+c()+c()+c()+c()+c()+c()}),f.extend=function(e,t,n){for(var r in t)void 0!==e[r]&&!0!==n||(e[r]=t[r]);},f.filterObj=function(e,t){var n={};return f.isString(t)&&(t=t.split(p)),t.forEach(function(t){e.hasOwnProperty(t)&&(n[t]=e[t]);}),n},f.copy=function(e,t){return t=t||{},e?(Object.keys(e).forEach(function(n){f.exist(e[n])&&(t[n]=e[n]);}),t):t},f.copyWithNull=function(e,t){return t=t||{},e?(Object.keys(e).forEach(function(n){(f.exist(e[n])||f.isnull(e[n]))&&(t[n]=e[n]);}),t):t},f.findObjIndexInArray=function(e,t){e=e||[];var n=t.keyPath||"id",r=-1;return e.some(function(e,i){if(u(e,n)===t.value)return r=i,!0}),r},f.findObjInArray=function(e,t){var n=f.findObjIndexInArray(e,t);return -1===n?null:e[n]},f.mergeObjArray=function(){var e=[],t=[].slice.call(arguments,0,-1),n=arguments[arguments.length-1];f.isArray(n)&&(t.push(n),n={});var r,i=n.keyPath=n.keyPath||"id";for(n.sortPath=n.sortPath||i;!e.length&&t.length;)e=(e=t.shift()||[]).slice(0);return t.forEach(function(t){t&&t.forEach(function(t){-1!==(r=f.findObjIndexInArray(e,{keyPath:i,value:u(t,i)}))?e[r]=f.merge({},e[r],t):e.push(t);});}),n.notSort||(e=f.sortObjArray(e,n)),e},f.cutObjArray=function(e){var t=e.slice(0),n=arguments.length,r=[].slice.call(arguments,1,n-1),i=arguments[n-1];f.isObject(i)||(r.push(i),i={});var o,s=i.keyPath=i.keyPath||"id";return r.forEach(function(e){f.isArray(e)||(e=[e]),e.forEach(function(e){e&&(i.value=u(e,s),-1!==(o=f.findObjIndexInArray(t,i))&&t.splice(o,1));});}),t},f.sortObjArray=function(e,t){var n=(t=t||{}).sortPath||"id";s.insensitive=!!t.insensitive;var r,i,o,a=!!t.desc;return o=f.isFunction(t.compare)?t.compare:function(e,t){return r=u(e,n),i=u(t,n),a?s(i,r):s(r,i)},e.sort(o)},f.emptyFunc=function(){},f.isEmptyFunc=function(e){return e===f.emptyFunc},f.notEmptyFunc=function(e){return e!==f.emptyFunc},f.splice=function(e,t,n){return [].splice.call(e,t,n)},f.reshape2d=function(e,t){if(Array.isArray(e)){f.verifyParamType("type",t,"number","util::reshape2d");var n=e.length;if(n<=t)return [e];for(var r=Math.ceil(n/t),i=[],o=0;o<r;o++)i.push(e.slice(o*t,(o+1)*t));return i}return e},f.flatten2d=function(e){if(Array.isArray(e)){var t=[];return e.forEach(function(e){t=t.concat(e);}),t}return e},f.dropArrayDuplicates=function(e){if(Array.isArray(e)){for(var t={},n=[];e.length>0;){t[e.shift()]=!0;}for(var r in t)!0===t[r]&&n.push(r);return n}return e},f.onError=function(e){throw new a(e)},f.verifyParamPresent=function(e,t,n,r){n=n||"";var i=!1;switch(f.typeOf(t)){case"undefined":case"null":i=!0;break;case"string":""===t&&(i=!0);break;case"StrStrMap":case"object":Object.keys(t).length||(i=!0);break;case"array":t.length?t.some(function(e){if(f.notexist(e))return i=!0,!0}):i=!0;}i&&f.onParamAbsent(n+e,r);},f.onParamAbsent=function(e,t){f.onParamError("缺少参数 "+e+", 请确保参数不是 空字符串、空对象、空数组、null或undefined, 或数组的内容不是 null/undefined",t);},f.verifyParamAbsent=function(e,t,n,r){n=n||"",void 0!==t&&f.onParamPresent(n+e,r);},f.onParamPresent=function(e,t){f.onParamError("多余的参数 "+e,t);},f.verifyParamType=function(e,t,n,r){var i=f.typeOf(t).toLowerCase();f.isArray(n)||(n=[n]);var o=!0;switch(-1===(n=n.map(function(e){return e.toLowerCase()})).indexOf(i)&&(o=!1),i){case"number":isNaN(t)&&(o=!1);break;case"string":"numeric or numeric string"===n.join("")&&(o=!!/^[0-9]+$/.test(t));}o||f.onParamInvalidType(e,n,"",r);},f.onParamInvalidType=function(e,t,n,r){n=n||"",t=f.isArray(t)?(t=t.map(function(e){return '"'+e+'"'})).join(", "):'"'+t+'"',f.onParamError('参数"'+n+e+'"类型错误, 合法的类型包括: ['+t+"]",r);},f.verifyParamValid=function(e,t,n,r){f.isArray(n)||(n=[n]),-1===n.indexOf(t)&&f.onParamInvalidValue(e,n,r);},f.onParamInvalidValue=function(e,t,n){f.isArray(t)||(t=[t]),t=t.map(function(e){return '"'+e+'"'}),f.isArray(t)&&(t=t.join(", ")),f.onParamError("参数 "+e+"值错误, 合法的值包括: ["+JSON.stringify(t)+"]",n);},f.verifyParamMin=function(e,t,n,r){t<n&&f.onParamError("参数"+e+"的值不能小于"+n,r);},f.verifyParamMax=function(e,t,n,r){t>n&&f.onParamError("参数"+e+"的值不能大于"+n,r);},f.verifyArrayMax=function(e,t,n,r){t.length>n&&f.onParamError("参数"+e+"的长度不能大于"+n,r);},f.verifyEmail=(l=/^\S+@\S+$/,function(e,t,n){l.test(t)||f.onParamError("参数"+e+"邮箱格式错误, 合法格式必须包含@符号, @符号前后至少要各有一个字符",n);}),f.verifyTel=function(){var e=/^[+\-()\d]+$/;return function(t,n,r){e.test(n)||f.onParamError("参数"+t+"电话号码格式错误, 合法字符包括+、-、英文括号和数字",r);}}(),f.verifyBirth=function(){var e=/^(\d{4})-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])$/;return function(t,n,r){e.test(n)||f.onParamError("参数"+t+'生日格式错误, 合法为"yyyy-MM-dd"',r);}}(),f.onParamError=function(e,t){f.onError({message:e,callFunc:t});},f.verifyOptions=function(e,t,n,r,i){if(e=e||{},t&&(f.isString(t)&&(t=t.split(p)),f.isArray(t))){"boolean"!=typeof n&&(i=n||null,n=!0,r="");var o=n?f.verifyParamPresent:f.verifyParamAbsent;t.forEach(function(t){o.call(f,t,e[t],r,i);});}return e},f.verifyParamAtLeastPresentOne=function(e,t,n){t&&(f.isString(t)&&(t=t.split(p)),f.isArray(t)&&(t.some(function(t){return f.exist(e[t])})||f.onParamError("以下参数["+t.join(", ")+"]至少需要传入一个",n)));},f.verifyParamPresentJustOne=function(e,t,n){t&&(f.isString(t)&&(t=t.split(p)),f.isArray(t)&&1!==t.reduce(function(t,n){return f.exist(e[n])&&t++,t},0)&&f.onParamError("以下参数["+t.join(", ")+"]必须且只能传入一个",n));},f.verifyBooleanWithDefault=function(e,t,n,r,i){f.undef(n)&&(n=!0),p.test(t)&&(t=t.split(p)),f.isArray(t)?t.forEach(function(t){f.verifyBooleanWithDefault(e,t,n,r,i);}):void 0===e[t]?e[t]=n:f.isBoolean(e[t])||f.onParamInvalidType(t,"boolean",r,i);},f.verifyFileInput=function(e,t){return f.verifyParamPresent("fileInput",e,"",t),f.isString(e)&&((e="undefined"==typeof document?void 0:document.getElementById(e))||f.onParamError("找不到要上传的文件对应的input, 请检查fileInput id "+e,t)),e.tagName&&"input"===e.tagName.toLowerCase()&&"file"===e.type.toLowerCase()||f.onParamError("请提供正确的 fileInput, 必须为 file 类型的 input 节点 tagname:"+e.tagName+", filetype:"+e.type,t),e},f.verifyFileType=function(e,t){f.verifyParamValid("type",e,f.validFileTypes,t);},f.verifyCallback=function(e,t,n){p.test(t)&&(t=t.split(p)),f.isArray(t)?t.forEach(function(t){f.verifyCallback(e,t,n);}):e[t]?f.isFunction(e[t])||f.onParamInvalidType(t,"function","",n):e[t]=f.emptyFunc;},f.verifyFileUploadCallback=function(e,t){f.verifyCallback(e,"uploadprogress uploaddone uploaderror uploadcancel",t);},f.validFileTypes=["image","audio","video","file"],f.validFileExts={image:["bmp","gif","jpg","jpeg","jng","png","webp"],audio:["mp3","wav","aac","wma","wmv","amr","mp2","flac","vorbis","ac3"],video:["mp4","rm","rmvb","wmv","avi","mpg","mpeg"]},f.filterFiles=function(e,t){var n,r,i="file"===(t=t.toLowerCase()),o=[];return [].forEach.call(e,function(e){if(i)o.push(e);else if(n=e.name.slice(e.name.lastIndexOf(".")+1),(r=e.type.split("/"))[0]&&r[1]){(r[0].toLowerCase()===t||-1!==f.validFileExts[t].indexOf(n))&&o.push(e);}}),o};var h,g,_=f.supportFormData=f.notundef(d.FormData);f.getFileName=function(e){return e=f.verifyFileInput(e),_?e.files[0].name:e.value.slice(e.value.lastIndexOf("\\")+1)},f.getFileInfo=(h={ppt:1,pptx:2,pdf:3},function(e){var t={};if(!(e=f.verifyFileInput(e)).files)return t;var n=e.files[0];return _&&(t.name=n.name,t.size=n.size,t.type=n.name.match(/\.(\w+)$/),t.type=t.type&&t.type[1].toLowerCase(),t.transcodeType=h[t.type]||0),t}),f.sizeText=(g=["B","KB","MB","GB","TB","PB","EB","ZB","BB"],function(e){var t,n=0;do{t=(e=Math.floor(100*e)/100)+g[n],e/=1024,n++;}while(e>1);return t}),f.promises2cmds=function(e){return e.map(function(e){return e.cmd})},f.objs2accounts=function(e){return e.map(function(e){return e.account})},f.teams2ids=function(e){return e.map(function(e){return e.teamId})},f.objs2ids=function(e){return e.map(function(e){return e.id})},f.getMaxUpdateTime=function(e){var t=e.map(function(e){return +e.updateTime});return Math.max.apply(Math,t)},f.genCheckUniqueFunc=function(e,t){return e=e||"id",function(t){this.uniqueSet=this.uniqueSet||{},this.uniqueSet[e]=this.uniqueSet[e]||{};var n=this.uniqueSet[e],r=t[e];return !n[r]&&(n[r]=!0,!0)}},f.fillPropertyWithDefault=function(e,t,n){return !!f.undef(e[t])&&(e[t]=n,!0)},e.exports=f;},function(e,t){e.exports=function e(t,n){var r,i,o=/(^([+\-]?(?:0|[1-9]\d*)(?:\.\d*)?(?:[eE][+\-]?\d+)?)?$|^0x[0-9a-f]+$|\d+)/gi,s=/(^[ ]*|[ ]*$)/g,u=/(^([\w ]+,?[\w ]+)?[\w ]+,?[\w ]+\d+:\d+(:\d+)?[\w ]?|^\d{1,4}[\/\-]\d{1,4}[\/\-]\d{1,4}|^\w+, \w+ \d+, \d{4})/,a=/^0x[0-9a-f]+$/i,c=/^0/,l=function(t){return e.insensitive&&(""+t).toLowerCase()||""+t},f=l(t).replace(s,"")||"",d=l(n).replace(s,"")||"",p=f.replace(o,"\0$1\0").replace(/\0$/,"").replace(/^\0/,"").split("\0"),h=d.replace(o,"\0$1\0").replace(/\0$/,"").replace(/^\0/,"").split("\0"),g=parseInt(f.match(a),16)||1!==p.length&&f.match(u)&&Date.parse(f),_=parseInt(d.match(a),16)||g&&d.match(u)&&Date.parse(d)||null;if(_){if(g<_)return -1;if(g>_)return 1}for(var m=0,v=Math.max(p.length,h.length);m<v;m++){if(r=!(p[m]||"").match(c)&&parseFloat(p[m])||p[m]||0,i=!(h[m]||"").match(c)&&parseFloat(h[m])||h[m]||0,isNaN(r)!==isNaN(i))return isNaN(r)?1:-1;if(typeof r!=typeof i&&(r+="",i+=""),r<i)return -1;if(r>i)return 1}return 0};},function(e,t){e.exports=function(e,t){var n=t.split(".");for(;n.length;){var r=n.shift(),i=!1;if("?"==r[r.length-1]&&(r=r.slice(0,-1),i=!0),!(e=e[r])&&i)return e}return e};},function(e,t,n){var r=n(64);"undefined"!=typeof window&&(window.console||r.isWeixinApp||(window.console={log:function(){},info:function(){},warn:function(){},error:function(){}}));},function(e,t,n){(function(e){Object.defineProperty(t,"__esModule",{value:!0}),t.url2origin=t.uniqueID=t.off=t.removeEventListener=t.on=t.addEventListener=t.format=t.regWhiteSpace=t.regBlank=t.emptyFunc=t.f=t.emptyObj=t.o=void 0;var r,i=n(12),o=(r=i)&&r.__esModule?r:{default:r};t.getGlobal=s,t.detectCSSFeature=function(e){var t=!1,n="Webkit Moz ms O".split(" ");if("undefined"==typeof document)return void console.log("error:fn:detectCSSFeature document is undefined");var r=document.createElement("div"),i=null;e=e.toLowerCase(),void 0!==r.style[e]&&(t=!0);if(!1===t){i=e.charAt(0).toUpperCase()+e.substr(1);for(var o=0;o<n.length;o++)if(void 0!==r.style[n[o]+i]){t=!0;break}}return t},t.fix=u,t.getYearStr=a,t.getMonthStr=c,t.getDayStr=l,t.getHourStr=f,t.getMinuteStr=d,t.getSecondStr=p,t.getMillisecondStr=h,t.dateFromDateTimeLocal=function(e){return e=""+e,new Date(e.replace(/-/g,"/").replace("T"," "))},t.getClass=m,t.typeOf=v,t.isString=y,t.isNumber=function(e){return "number"===v(e)},t.isBoolean=function(e){return "boolean"===v(e)},t.isArray=b,t.isFunction=E,t.isDate=O,t.isRegExp=function(e){return "regexp"===v(e)},t.isError=function(e){return "error"===v(e)},t.isnull=T,t.notnull=k,t.undef=A,t.notundef=N,t.exist=I,t.notexist=C,t.isObject=w,t.isEmpty=function(e){return C(e)||(y(e)||b(e))&&0===e.length},t.containsNode=function(e,t){if(e===t)return !0;for(;t.parentNode;){if(t.parentNode===e)return !0;t=t.parentNode;}return !1},t.calcHeight=function(e){var t=e.parentNode||("undefined"==typeof document?null:document.body);if(!t)return 0;(e=e.cloneNode(!0)).style.display="block",e.style.opacity=0,e.style.height="auto",t.appendChild(e);var n=e.offsetHeight;return t.removeChild(e),n},t.remove=function(e){e.parentNode&&e.parentNode.removeChild(e);},t.dataset=function(e,t,n){if(!I(n))return e.getAttribute("data-"+t);e.setAttribute("data-"+t,n);},t.target=function(e){return e.target||e.srcElement},t.createIframe=function(e){if("undefined"==typeof document)return;var t;if((e=e||{}).name)try{(t=document.createElement('<iframe name="'+e.name+'"></iframe>')).frameBorder=0;}catch(n){(t=document.createElement("iframe")).name=e.name;}else t=document.createElement("iframe");e.visible||(t.style.display="none");E(e.onload)&&R(t,"load",function n(r){if(!t.src)return;e.multi||L(t,"load",n);e.onload(r);});(e.parent||document.body).appendChild(t);var n=e.src||"about:blank";return setTimeout(function(){t.src=n;},0),t},t.html2node=function(e){if("undefined"==typeof document)return;var t=document.createElement("div");t.innerHTML=e;var n=[],r=void 0,i=void 0;if(t.children)for(r=0,i=t.children.length;r<i;r++)n.push(t.children[r]);else for(r=0,i=t.childNodes.length;r<i;r++){var o=t.childNodes[r];1===o.nodeType&&n.push(o);}return n.length>1?t:n[0]},t.scrollTop=function(e){"undefined"!=typeof document&&I(e)&&(document.documentElement.scrollTop=document.body.scrollTop=e);return window.pageYOffset||document.documentElement.scrollTop||document.body.scrollTop||0},t.forOwn=P,t.mixin=F,t.isJSON=D,t.parseJSON=function e(t){try{D(t)&&(t=JSON.parse(t)),w(t)&&P(t,function(n,r){switch(v(r)){case"string":case"object":t[n]=e(r);}});}catch(e){console.log("error:",e);}return t},t.simpleClone=function(e){var t=[],n=JSON.stringify(e,function(e,n){if("object"===(void 0===n?"undefined":(0, o.default)(n))&&null!==n){if(-1!==t.indexOf(n))return;t.push(n);}return n});return JSON.parse(n)},t.merge=function(){for(var e=arguments.length>0&&void 0!==arguments[0]?arguments[0]:{},t=arguments.length,n=Array(t>1?t-1:0),r=1;r<t;r++)n[r-1]=arguments[r];return n.forEach(function(t){F(e,t);}),e},t.fillUndef=function(e,t){return P(t,function(t,n){A(e[t])&&(e[t]=n);}),e},t.checkWithDefault=function(e,t,n){var r=e[t]||e[t.toLowerCase()];C(r)&&(r=n,e[t]=r);return r},t.fetch=function(e,t){return P(e,function(n,r){I(t[n])&&(e[n]=t[n]);}),e},t.string2object=function(){var e=arguments.length>0&&void 0!==arguments[0]?arguments[0]:"",t=arguments.length>1&&void 0!==arguments[1]?arguments[1]:",",n={};return e.split(t).forEach(function(e){var t=e.split("="),r=t.shift();r&&(n[decodeURIComponent(r)]=decodeURIComponent(t.join("=")));}),n},t.object2string=j,t.genUrlSep=function(e){return e.indexOf("?")<0?"?":"&"},t.object2query=function(e){return j(e,"&",!0)},t.isFileInput=B,t.getKeys=function(e,t){var n=Object.keys(e);t&&n.sort(function(t,n){var r=B(e[t]),i=B(e[n]);return r===i?0:r?1:-1});return n};t.o={},t.emptyObj={},t.f=function(){},t.emptyFunc=function(){},t.regBlank=/\s+/gi,t.regWhiteSpace=/\s+/gi;function s(){return "undefined"!=typeof window?window:void 0!==e?e:{}}function u(e,t){t=t||2;for(var n=""+e;n.length<t;)n="0"+n;return n}function a(e){return ""+e.getFullYear()}function c(e){return u(e.getMonth()+1)}function l(e){return u(e.getDate())}function f(e){return u(e.getHours())}function d(e){return u(e.getMinutes())}function p(e){return u(e.getSeconds())}function h(e){return u(e.getMilliseconds(),3)}var g,_;t.format=(g=/yyyy|MM|dd|hh|mm|ss|SSS/g,_={yyyy:a,MM:c,dd:l,hh:f,mm:d,ss:p,SSS:h},function(e,t){return e=new Date(e),isNaN(+e)?"invalid date":(t=t||"yyyy-MM-dd").replace(g,function(t){return _[t](e)})});function m(e){return Object.prototype.toString.call(e).slice(8,-1)}function v(e){return m(e).toLowerCase()}function y(e){return "string"===v(e)}function b(e){return "array"===v(e)}function E(e){return "function"===v(e)}function O(e){return "date"===v(e)}function T(e){return null===e}function k(e){return null!==e}function A(e){return void 0===e}function N(e){return void 0!==e}function I(e){return N(e)&&k(e)}function C(e){return A(e)||T(e)}function w(e){return I(e)&&"object"===v(e)}var S=t.addEventListener=function(e,t,n){e.addEventListener?e.addEventListener(t,n,!1):e.attachEvent&&e.attachEvent("on"+t,n);},R=t.on=S,x=t.removeEventListener=function(e,t,n){e.removeEventListener?e.removeEventListener(t,n,!1):e.detachEvent&&e.detachEvent("on"+t,n);},L=t.off=x;function P(){var e=arguments.length>0&&void 0!==arguments[0]?arguments[0]:{},t=arguments.length>1&&void 0!==arguments[1]?arguments[1]:function(){},n=arguments[2];for(var r in e)e.hasOwnProperty(r)&&t.call(n,r,e[r]);}function F(e,t){P(t,function(t,n){e[t]=n;});}var U;t.uniqueID=(U=0,function(){return ""+U++});function D(e){return y(e)&&0===e.indexOf("{")&&e.lastIndexOf("}")===e.length-1}function j(e,t,n){if(!e)return "";var r=[];return P(e,function(e,t){E(t)||(O(t)?t=t.getTime():b(t)?t=t.join(","):w(t)&&(t=JSON.stringify(t)),n&&(t=encodeURIComponent(t)),r.push(encodeURIComponent(e)+"="+t));}),r.join(t||",")}t.url2origin=function(){var e=/^([\w]+?:\/\/.*?(?=\/|$))/i;return function(t){return e.test(t||"")?RegExp.$1.toLowerCase():""}}();function B(e){var t=s();return e.tagName&&"INPUT"===e.tagName.toUpperCase()||t.Blob&&e instanceof t.Blob}}).call(this,n(138));},function(e,t){var n;n=function(){return this}();try{n=n||new Function("return this")();}catch(e){"object"==typeof window&&(n=window);}e.exports=n;},function(e,t,n){var r,i=n(12),o=(r=i)&&r.__esModule?r:{default:r};e.exports=function(){var e=arguments.length>0&&void 0!==arguments[0]?arguments[0]:{},t=this;if(e.maxLogsLines&&"number"==typeof e.maxLogsLines&&!isNaN(e.maxLogsLines)||(e.maxLogsLines=5e3),e.logFilename&&(e.logFilename=e.logFilename+".txt"),t.useTimestamps=e.useTimestamps||!1,t.useLocalStorage=e.useLocalStorage||!1,t.autoTrim=!0,t.maxLines=e.maxLogsLines||5e3,t.tailNumLines=100,t.logFilename=e.logFilename||"nimWebRtcLog.txt",t.maxDepth=5,t.depth=0,t.parentSizes=[0],t.currentResult="",t.startTime=new Date,t.output="",this.getLog=function(){var e=new Date;if(t.useLocalStorage){var n=window.localStorage.getItem("nimWebRtcLog");n&&(n=JSON.parse(n),t.startTime=new Date(n.startTime),t.output=n.log,e=new Date(n.lastLog));}return t.output+"\n---- Log retrieved: "+e+" ----\n"+t.formatSessionDuration(t.startTime,e)},this.tail=function(e){return e=e||t.tailLines,t.trimLog(t.getLog(),e)},this.search=function(e){for(var n=t.output.split("\n"),r=new RegExp(e),i=[],o=0;o<n.length;o++){var s="["+o+"] ";n[o].match(r)&&i.push(s+n[o]);}var u=i.join("\n");return 0==u.length&&(u='Nothing found for "'+e+'".'),u},this.getSlice=function(e,n){return t.output.split("\n").slice(e,e+n).join("\n")},this.downloadLog=function(){var e=t.getLog(),n=new Blob([e],{type:"data:text/plain;charset=utf-8"}),r=document.createElement("a");r.href=window.URL.createObjectURL(n),r.target="_blank",r.download=t.logFilename,document.body.appendChild(r),r.click(),document.body.removeChild(r),window.URL.revokeObjectURL(r.href);},this.clear=function(){var e=new Date;if(t.output="---- Log cleared: "+e+" ----\n",t.useLocalStorage){var n={startTime:t.startTime,log:t.output,lastLog:e};n=JSON.stringify(n),window.localStorage.setItem("nimWebRtcLog",n);}},this.log=function(e){var n=t.determineType(e);if(null!=n){var r=t.formatType(n,e);if(t.useTimestamps){var i=new Date;t.output+=t.formatTimestamp(i);}if(t.output+=r+"\n",t.autoTrim&&(t.output=t.trimLog(t.output,t.maxLines)),t.useLocalStorage){var o=new Date,s={startTime:t.startTime,log:t.output,lastLog:o};s=JSON.stringify(s),window.localStorage.setItem("nimWebRtcLog",s);}}t.depth=0,t.parentSizes=[0],t.currentResult="";},this.determineType=function(e){if(null!=e){var t=void 0===e?"undefined":(0, o.default)(e);return "object"==t?null==e.length?"function"==typeof e.getTime?"Date":"function"==typeof e.test?"RegExp":"Object":"Array":t}return null},this.formatType=function(e,n){if(t.maxDepth&&t.depth>=t.maxDepth)return "... (max-depth reached)";switch(e){case"Object":t.currentResult+="{\n",t.depth++,t.parentSizes.push(t.objectSize(n));var r=0;for(var i in n){t.currentResult+=t.indentsForDepth(t.depth),t.currentResult+=i+": ";var o=t.determineType(n[i]);(s=t.formatType(o,n[i]))?("function"!==o&&(t.currentResult+=s),r!=t.parentSizes[t.depth]-1&&(t.currentResult+=","),t.currentResult+="\n"):(r!=t.parentSizes[t.depth]-1&&(t.currentResult+=","),t.currentResult+="\n"),r++;}if(t.depth--,t.parentSizes.pop(),t.currentResult+=t.indentsForDepth(t.depth),t.currentResult+="}",0==t.depth)return t.currentResult;break;case"Array":for(t.currentResult+="[",t.depth++,t.parentSizes.push(n.length),r=0;r<n.length;r++){var s;"Object"!=(o=t.determineType(n[r]))&&"Array"!=o||(t.currentResult+="\n"+t.indentsForDepth(t.depth)),(s=t.formatType(o,n[r]))?(t.currentResult+=s,r!=t.parentSizes[t.depth]-1&&(t.currentResult+=", "),"Array"==o&&(t.currentResult+="\n")):(r!=t.parentSizes[t.depth]-1&&(t.currentResult+=", "),"Object"!=o?t.currentResult+="\n":r==t.parentSizes[t.depth]-1&&(t.currentResult+="\n"));}if(t.depth--,t.parentSizes.pop(),t.currentResult+="]",0==t.depth)return t.currentResult;break;case"function":var u=(n+="").split("\n");for(r=0;r<u.length;r++)u[r].match(/\}/)&&t.depth--,t.currentResult+=t.indentsForDepth(t.depth),u[r].match(/\{/)&&t.depth++,t.currentResult+=u[r]+"\n";return t.currentResult;case"RegExp":return "/"+n.source+"/";case"Date":case"string":return t.depth>0||0==n.length?'"'+n+'"':n;case"boolean":return n?"true":"false";case"number":return n+""}},this.indentsForDepth=function(e){for(var t="",n=0;n<e;n++)t+="\t";return t},this.trimLog=function(e,t){var n=e.split("\n");return n.length>t&&(n=n.slice(n.length-t)),n.join("\n")},this.lines=function(){return t.output.split("\n").length},this.formatSessionDuration=function(e,t){var n=t-e,r=Math.floor(n/1e3/60/60),i=("0"+r).slice(-2);n-=1e3*r*60*60;var o=Math.floor(n/1e3/60),s=("0"+o).slice(-2);n-=1e3*o*60;var u=Math.floor(n/1e3);return n-=1e3*u,"---- Session duration: "+i+":"+s+":"+("0"+u).slice(-2)+" ----"},this.formatTimestamp=function(e){var t=e.getFullYear(),n=e.getDate();return "["+t+"-"+("0"+(e.getMonth()+1)).slice(-2)+"-"+n+" "+Number(e.getHours())+":"+("0"+e.getMinutes()).slice(-2)+":"+("0"+e.getSeconds()).slice(-2)+"]: "},this.objectSize=function(e){var t,n=0;for(t in e)e.hasOwnProperty&&e.hasOwnProperty(t)&&n++;return n},t.useLocalStorage){var n=window.localStorage.getItem("nimWebRtcLog");if(n){n=JSON.parse(n),t.output=n.log;var r=new Date(n.startTime),i=new Date(n.lastLog);t.output+="\n---- Session end: "+n.lastLog+" ----\n",t.output+=t.formatSessionDuration(r,i),t.output+="\n\n";}}t.output+="---- Session started: "+t.startTime+" ----\n\n";};},function(e,t,n){Object.defineProperty(t,"__esModule",{value:!0});var r=c(n(41)),i=c(n(42)),o=c(n(27)),s=n(14),u=c(n(141)),a=c(n(65));function c(e){return e&&e.__esModule?e:{default:e}}var l=n(64),f=n(44).version,d=n(28),p={init:function(){return Promise.resolve()},setVoiceBeautifierPreset:function(e){var t=this;return (0, i.default)(r.default.mark(function n(){return r.default.wrap(function(n){for(;;)switch(n.prev=n.next){case 0:if(t.logger.log("NErtc::setVoiceBeautifierPreset type: "+e),!(!Number.isInteger(e)||e<0||e>11)){n.next=4;break}return t.logger.log("NErtc::setVoiceBeautifierPreset type参数错误"),n.abrupt("return",Promise.reject(Object.assign(s.CONSTANT_ERROR.invalidOperation,{reason:"setVoiceBeautifierPreset接口type参数错误"})));case 4:if(!t._status.isInTheRoom){n.next=19;break}if(e===s.VOICE_BEAUTIFIER_TYPE.VOICE_BEAUTIFIER_OFF){n.next=15;break}return t.logger.log("NErtc::setVoiceBeautifierPreset 设置为美声处理"),t._status.audioChangeMode=2,n.next=10,t._wsController.updateAudioChangeMode(2);case 10:return t.logger.log("NErtc::setVoiceBeautifierPreset 设置为美声模式为 "+e),n.next=13,t._wsController.updateVoiceBeautifierPreset(e);case 13:n.next=19;break;case 15:if(2!=t._status.audioChangeMode){n.next=19;break}return t.logger.log("NErtc::setVoiceBeautifierPreset 设置为不处理"),n.next=19,t._wsController.updateAudioChangeMode(0);case 19:e!==s.VOICE_BEAUTIFIER_TYPE.VOICE_BEAUTIFIER_OFF&&(t.logger.warn("NErtc::setVoiceBeautifierPreset 设置了美声声，将音调和变声恢复到默认值"),t._status.pitch="1.25",t._status.voiceEffectType=s.VOICE_EFFECT_TYPE.AUDIO_EFFECT_OFF),t._status.voiceBeautifierType=e,t.apiEventReport("setFunction",{name:"setVoiceBeautifierPreset",oper:"音频美声",value:JSON.stringify({type:e},null," ")});case 22:case"end":return n.stop()}},n,t)}))()},setAudioEffectPreset:function(e){var t=this;return (0, i.default)(r.default.mark(function n(){return r.default.wrap(function(n){for(;;)switch(n.prev=n.next){case 0:if(t.logger.log("NErtc::setAudioEffectPreset type: "+e),!(!Number.isInteger(e)||e<0||e>8)){n.next=4;break}return t.logger.log("NErtc::setAudioEffectPreset type参数错误"),n.abrupt("return",Promise.reject(Object.assign(s.CONSTANT_ERROR.invalidOperation,{reason:"setAudioEffectPreset接口type参数错误"})));case 4:if(!t._status.isInTheRoom){n.next=18;break}if(e===s.VOICE_EFFECT_TYPE.AUDIO_EFFECT_OFF){n.next=15;break}return t.logger.log("NErtc::setAudioEffectPreset 设置为变声处理"),t._status.audioChangeMode=1,n.next=10,t._wsController.updateAudioChangeMode(1);case 10:return t.logger.log("NErtc::setAudioEffectPreset 设置为变声模式为 "+e),n.next=13,t._wsController.updateAudioEffectPreset(e);case 13:n.next=18;break;case 15:if(1!=t._status.audioChangeMode){n.next=18;break}return n.next=18,t._wsController.updateAudioChangeMode(0);case 18:t._status.voiceEffectType=e,e!==s.VOICE_EFFECT_TYPE.AUDIO_EFFECT_OFF&&(t.logger.warn("NErtc::setAudioEffectPreset 设置了变声，将音调和美声恢复到默认值"),t._status.pitch="1.25",t._status.voiceBeautifierType=s.VOICE_BEAUTIFIER_TYPE.VOICE_BEAUTIFIER_OFF),t.apiEventReport("setFunction",{name:"setAudioEffectPreset",oper:"音频变声",value:JSON.stringify({type:e},null," ")});case 21:case"end":return n.stop()}},n,t)}))()},setLocalVoicePitch:function(e){var t=this;return (0, i.default)(r.default.mark(function n(){return r.default.wrap(function(n){for(;;)switch(n.prev=n.next){case 0:if(t.logger.log("NErtc::setLocalVoicePitch pitch: "+e),!("number"==typeof e&&e>=.5&&e<=2)){n.next=4;break}n.next=6;break;case 4:return t.logger.log("NErtc::setLocalVoicePitch pitch参数错误"),n.abrupt("return",Promise.reject(Object.assign(s.CONSTANT_ERROR.invalidOperation,{reason:"setLocalVoicePitch接口pitch参数错误"})));case 6:if(!t._status.isInTheRoom){n.next=22;break}if(1.25==e){n.next=19;break}return t._status.audioChangeMode=1,n.next=11,t._wsController.updateAudioChangeMode(1);case 11:return t.logger.log("NErtc::setLocalVoicePitch 设置本地语音音调, 先关闭之前的变声设置: ",t._status.voiceEffectType),n.next=14,t._wsController.updateAudioEffectPreset(s.VOICE_EFFECT_TYPE.AUDIO_EFFECT_OFF);case 14:return t.logger.log("NErtc::setLocalVoicePitch 设置本地语音音调, pitch: ",e),n.next=17,t._wsController.updateLocalVoicePitch(e+"");case 17:n.next=22;break;case 19:if(1!=t._status.audioChangeMode){n.next=22;break}return n.next=22,t._wsController.updateAudioChangeMode(0);case 22:1.25!=e&&(t.logger.warn("NErtc::setLocalVoicePitch 设置了音调，将变声和美声恢复到默认值"),t._status.voiceEffectType=s.VOICE_EFFECT_TYPE.AUDIO_EFFECT_OFF,t._status.voiceBeautifierType=s.VOICE_BEAUTIFIER_TYPE.VOICE_BEAUTIFIER_OFF),t._status.pitch=e+"",t.apiEventReport("setFunction",{name:"setLocalVoiceEqualization",oper:"语音音调",value:JSON.stringify({pitch:e},null," ")});case 25:case"end":return n.stop()}},n,t)}))()},setLocalVoiceEqualization:function(e,t){var n=this;return (0, i.default)(r.default.mark(function i(){var o;return r.default.wrap(function(r){for(;;)switch(r.prev=r.next){case 0:if(n.logger.log("NErtc::setLocalVoiceEqualization bandFrequency: "+e+", gain: "+t),n._status.audioEqualizationBand[e]=t,!n._status.isInTheRoom){r.next=15;break}if(console.warn("this._status.audioChangeMode: ",n._status.audioChangeMode),2===n._status.audioChangeMode){r.next=8;break}return n._status.audioChangeMode=2,r.next=8,n._wsController.updateAudioChangeMode(2);case 8:return o=Object.values(n._status.audioEqualizationBand).join(),n.logger.log("NErtc::setLocalVoiceEqualization 更新本地语音音效均衡, equa: ",o),r.next=12,n._wsController.updateLocalVoiceEqualization(o);case 12:n.logger.warn("NErtc::setLocalVoiceEqualization 设置了美声，将音调和变声恢复到默认值"),n._status.pitch="1.25",n._status.voiceEffectType=s.VOICE_EFFECT_TYPE.AUDIO_EFFECT_OFF;case 15:n.apiEventReport("setFunction",{name:"setLocalVoiceEqualization",oper:"语音音效均衡",value:JSON.stringify({bandFrequency:e,gain:t},null," ")});case 16:case"end":return r.stop()}},i,n)}))()},setRole:function(){var e=this,t=arguments.length>0&&void 0!==arguments[0]?arguments[0]:"broadcaster";return (0, i.default)(r.default.mark(function n(){return r.default.wrap(function(n){for(;;)switch(n.prev=n.next){case 0:if(e.logger.log("NErtc::setRole role:"+t+", publishAudio: "+e._status.publishAudio+", publishVideo: "+e._status.publishVideo),e._status.role=t,e._status.isInTheRoom){n.next=5;break}return e.logger.log("NErtc::setRole 当前不在房间中"),n.abrupt("return");case 5:if(n.prev=5,"audience"!=t){n.next=13;break}if(!e._status.publishAudio){n.next=10;break}return n.next=10,e.unpublish("audio");case 10:if(!e._status.publishVideo){n.next=13;break}return n.next=13,e.unpublish("video");case 13:return n.next=15,e._wsController.changeRole("audience"==t?1:0);case 15:return e.apiEventReport("setFunction",{name:"setRole",oper:"1",value:t}),n.abrupt("return");case 19:return n.prev=19,n.t0=n.catch(5),n.abrupt("return",Promise.reject(n.t0));case 22:case"end":return n.stop()}},n,e,[[5,19]])}))()},join:function(e){var t=this;if(this._status.isInTheRoom)return this.logger.log("正在房间中，请勿重复加入！"),Promise.reject(Object.assign(s.CONSTANT_ERROR.invalidOperation,{reason:"重复加入房间"}));this.logger.log("join: "+JSON.stringify(e,null," ")),this._updateStatus({isInTheRoom:!0});var n=this,r=null;o.default.verifyOptions(e,"channelName"),"number"!=typeof e.uid||isNaN(e.uid)?"string"==typeof e.uid?(this.logger.log("uid是string"),r=new d(e.uid)):d.isBigNumber(e.uid)?r=e.uid:null!=e.uid&&null!=e.uid||(r=new d(o.default.uuid())):(this.logger.log("uid是number"),r=e.uid),n._updateStatus({joinChannelParam:e}),e.scene=s.SESSION_MODE.MEETING,n._dataReporter.updateStatistics(Object.assign({},{appkey:n._status.appkey,uid:r,miniapp_mode:e.mode?e.mode:0,platform:n._status.runtimeEnvironment},{meeting:{value:1}}));var i=+new Date,u=Date.now();n._info.joinChannelParam=e;var c=l.miniG2.getChannelInfoUrl;return e.channelServer&&(c=e.channelServer),this._status.channelServer=e.channelServer,this._status.statisticsServer=e.statisticsServer,this._status.roomServer=e.roomServer,this._dataReporter&&this._dataReporter.updateStatisticsServer(e.statisticsServer),this._info.uid=r,new Promise(function(l,p){return o.default.post({uid:r,appkey:n._status.appkey,channelName:e.channelName,secureType:e.token?"1":"2",osType:"4",mode:2,netType:"0",version:f+".0"||!1,curtime:i,checksum:e.token?e.token:(0, a.default)(n._status.appkey+"."+r.toString()+"."+i),nrtcg2:1,t1:u},{url:c,runtimeEnvironment:t._status.runtimeEnvironment}).then(function(i){if(200===i.code){var o=i.ips,u=void 0===o?{}:o,a=i.time,c=void 0===a?{}:a;if(!u.wechatapparray)return t.logger.error("服务器没有返回网关地址，加入房间失败"),t.apiEventReport("setLogin",{a_record:!!n._info.joinChannelParam.recordAudio,v_record:!!n._info.joinChannelParam.recordVideo,record_type:n._info.joinChannelParam.recordType?n._info.joinChannelParam.recordType+"":"0",host_speaker:!!n._info.joinChannelParam.isHostSpeaker,result:s.CONSTANT_ERROR.getChannelInfoFail.code,reason:s.CONSTANT_ERROR.getChannelInfoFail.reason,serverIp:""}),n._updateStatus({isInTheRoom:!1}),p(s.CONSTANT_ERROR.getChannelInfoFail);Object.assign(n._status.createChannelResponse,i,e),n._status.createChannelResponse.token=i.token,n._status.createChannelResponse.uid=r,n._info.T4=Date.now();var f=n._info.T4-c.t1-(c.t3-c.t2);n._info.clientNtpTime=c.t3+Math.round(f/2);var h=n._generateJoinParam(e);h.role="broadcaster"===t._status.role?0:1,h.dualAudio=0,t._status.voiceEffectType?h.audioChangeMode=1:t._status.voiceBeautifierType?h.audioChangeMode=2:h.audioChangeMode=0,t._status.audioChangeMode=h.audioChangeMode,h.audioLocalPitch=""+t._status.pitch,h.audioChangeType=t._status.voiceEffectType,h.audioBeautyType=t._status.voiceBeautifierType,n._info.dualAudio=h.dualAudio,n._info.joinChannelParam=h,n._info.turnToken=u.token,n._wsController.joinChannel(h).then(function(){t._info.cid=i.cid,n._dataReporter.updateStatistics({cid:t._info.cid,appkey:n._status.appkey,uid:r}),t.logger.log("开始joinChannel 加入房间成功"),l({cid:i.cid,code:i.code,uid:d.isBigNumber(r)?r.toString():r});}).catch(function(e){t.logger.error("开始joinChannel 加入房间失败: ",e),p(e);});}else t.logger.error("小程序网关地址请求失败: ",i),t.apiEventReport("setLogin",{a_record:!!n._info.joinChannelParam.recordAudio,v_record:!!n._info.joinChannelParam.recordVideo,record_type:n._info.joinChannelParam.recordType?n._info.joinChannelParam.recordType+"":"0",host_speaker:!!n._info.joinChannelParam.isHostSpeaker,result:i.code,reason:"http request error",serverIp:n._info.joinChannelParam.address||""}),n._updateStatus({isInTheRoom:!1}),p({code:i.code,reason:"http request error"});}).catch(function(e){t.logger.error("join() 语法错误: ",e),t.apiEventReport("setLogin",{a_record:!!n._info.joinChannelParam.recordAudio,v_record:!!n._info.joinChannelParam.recordVideo,record_type:n._info.joinChannelParam.recordType?n._info.joinChannelParam.recordType+"":"0",host_speaker:!!n._info.joinChannelParam.isHostSpeaker,result:s.CONSTANT_ERROR.syntaxError.code,reason:e.message,serverIp:n._info.joinChannelParam.address||""}),n._updateStatus({isInTheRoom:!1}),p(Object.assign(s.CONSTANT_ERROR.syntaxError,{reason:e.message}));})})},publish:function(){var e=this,t=arguments.length>0&&void 0!==arguments[0]?arguments[0]:"";return (0, i.default)(r.default.mark(function n(){var o;return r.default.wrap(function(n){for(;;)switch(n.prev=n.next){case 0:if(e.logger.log("NErtc::publish mediaType:"+t+", publishAudio: "+e._status.publishAudio+", publishVideo: "+e._status.publishVideo+", role: "+e._status.role),o=null,e._status.isInTheRoom?"audio"!==t&&"video"!==t&&""!==t?(e.logger.log("NErtc::publish mediaType参数错误"),o=Object.assign(s.CONSTANT_ERROR.invalidOperation,{reason:"publish接口mediaType参数错误"})):"audience"==e._status.role&&(e.logger.log("NErtc::publish 当前是观众模式"),o=Object.assign(s.CONSTANT_ERROR.invalidOperation,{reason:"观众角色不允许publish"})):(e.logger.log("NErtc::publish 当前不在房间中，无法进行publish操作"),o=Object.assign(s.CONSTANT_ERROR.invalidOperation,{reason:"在join之前，不允许执行publish操作"})),!o){n.next=6;break}return e.apiEventReport("setFunction",{name:"publish",oper:t,value:JSON.stringify(o,null," ")}),n.abrupt("return",Promise.reject(o));case 6:if("audio"!==t||!e._status.publishAudio){n.next=11;break}return e.logger.log("NErtc::publish 音频已经publish，重复"),n.abrupt("return",e._info.pushUrl);case 11:if("video"!==t||!e._status.publishVideo){n.next=16;break}return e.logger.log("NErtc::publish 视频已经publish，重复"),n.abrupt("return",e._info.pushUrl);case 16:if(!e._status.publishAudio||!e._status.publishVideo){n.next=19;break}return e.logger.log("NErtc::publish 音视频已经publish，重复"),n.abrupt("return",e._info.pushUrl);case 19:return n.abrupt("return",new Promise(function(){var n=(0, i.default)(r.default.mark(function n(o,u){var a;return r.default.wrap(function(n){for(;;)switch(n.prev=n.next){case 0:a=setInterval((0, i.default)(r.default.mark(function n(){return r.default.wrap(function(n){for(;;)switch(n.prev=n.next){case 0:if(e.logger.log("NErtc::publish 定时器 推流地址： ",e._info.pushUrl),"broadcaster"===e._status.role){n.next=8;break}return e.logger.log("NErtc::publish 异步操作，角色已经发送了变化"),clearInterval(a),a=null,o(),e.apiEventReport("setFunction",{name:"publish",oper:t,value:"当前为观众角色"}),n.abrupt("return");case 8:if(!e._info.pushUrl){n.next=38;break}if(clearInterval(a),a=null,e.logger.log("NErtc::publish 定时器发送publish消息"),n.prev=12,!t){n.next=20;break}return e.logger.log("publish: ",t),n.next=17,e._wsController.publish(t);case 17:"audio"===t?e._status.publishAudio=!0:"video"===t&&(e._status.publishVideo=!0),n.next=30;break;case 20:if(e._status.publishAudio){n.next=24;break}return e.logger.log("publish audio"),n.next=24,e._wsController.publish("audio");case 24:if(e._status.publishVideo){n.next=28;break}return e.logger.log("publish video"),n.next=28,e._wsController.publish("video");case 28:e._status.publishAudio=!0,e._status.publishVideo=!0;case 30:o(e._info.pushUrl),e.apiEventReport("setFunction",{name:"publish",oper:t,value:JSON.stringify({publishAudio:e._status.publishAudio,publishVideo:e._status.publishVideo,pushUrl:e._info.pushUrl},null,"")}),n.next=38;break;case 34:n.prev=34,n.t0=n.catch(12),e.apiEventReport("setFunction",{name:"publish",oper:t,value:Object.stringify({code:n.t0&&n.t0.code,reason:n.t0&&n.t0.errMsg},null," ")}),u(n.t0);case 38:case"end":return n.stop()}},n,e,[[12,34]])})),100),setTimeout(function(){clearInterval(a),a=null,e._info.pushUrl||(e.logger.error("NErtc::publish 没有获取到推流地址"),e.apiEventReport("setFunction",{name:"publish",oper:t,value:JSON.stringify(s.CONSTANT_ERROR.publishFailed,null," ")}),u(s.CONSTANT_ERROR.publishFailed));},15e3);case 2:case"end":return n.stop()}},n,e)}));return function(e,t){return n.apply(this,arguments)}}()));case 20:case"end":return n.stop()}},n,e)}))()},unpublish:function(){var e=this,t=arguments.length>0&&void 0!==arguments[0]?arguments[0]:"";return (0, i.default)(r.default.mark(function n(){var i;return r.default.wrap(function(n){for(;;)switch(n.prev=n.next){case 0:if(e.logger.log("NErtc::unpublish mediaType:"+t+", publishAudio: "+e._status.publishAudio+", publishVideo: "+e._status.publishVideo),i=null,e._status.isInTheRoom){n.next=8;break}return e.logger.log("NErtc::unpublish 不正在房间中，请勿调用！"),i=Object.assign(s.CONSTANT_ERROR.invalidOperation,{reason:"在join之前，不允许执行unpublish操作"}),n.abrupt("return",Promise.reject());case 8:"audio"!==t&&"video"!==t&&""!==t&&(e.logger.log("NErtc::unpublish mediaType参数错误"),i=Object.assign(s.CONSTANT_ERROR.invalidOperation,{reason:"unpublish接口mediaType参数错误"}));case 9:if(!i){n.next=12;break}return e.apiEventReport("setFunction",{name:"unpublish",oper:t,value:Object.assign(i,null," ")}),n.abrupt("return",Promise.reject(i));case 12:if("audio"!==t||e._status.publishAudio){n.next=16;break}return n.abrupt("return");case 16:if("video"!==t||e._status.publishVideo){n.next=20;break}return n.abrupt("return");case 20:if(e._status.publishAudio||e._status.publishVideo){n.next=22;break}return n.abrupt("return");case 22:if(e.logger.log("NErtc::unpublish 停止发布媒体: ",e._info.pushUrl),n.prev=23,!t){n.next=30;break}return n.next=27,e._wsController.unpublish(t);case 27:"audio"===t?e._status.publishAudio=!1:"video"===t&&(e._status.publishVideo=!1),n.next=38;break;case 30:if(!e._status.audio){n.next=33;break}return n.next=33,e._wsController.unpublish("audio");case 33:if(!e._status.video){n.next=36;break}return n.next=36,e._wsController.unpublish("video");case 36:e._status.publishAudio=!1,e._status.publishVideo=!1;case 38:return e.apiEventReport("setFunction",{name:"unpublish",oper:t,value:"success"}),n.abrupt("return");case 42:return n.prev=42,n.t0=n.catch(23),e.apiEventReport("setFunction",{name:"unpublish",oper:t,value:Object.stringify({code:n.t0&&n.t0.code,reason:n.t0&&n.t0.errMsg},null," ")}),n.abrupt("return",Promise.reject(n.t0));case 46:case"end":return n.stop()}},n,e,[[23,42]])}))()},subscribe:function(e){var t=this,n=arguments.length>1&&void 0!==arguments[1]?arguments[1]:"";return (0, i.default)(r.default.mark(function i(){var o,u,a,c;return r.default.wrap(function(r){for(;;)switch(r.prev=r.next){case 0:if(o=null,t._status.isInTheRoom?"audio"!==n&&"video"!==n&&"slaveAudio"!==n&&"screenShare"!==n?(t.logger.log("NErtc::subscribe mediaType参数错误"),o=Object.assign(s.CONSTANT_ERROR.invalidOperation,{reason:"在join之前，不允许执行unpublish操作"})):e&&t._info.userlist.get(e.toString())||(t.logger.log("NErtc::subscribe "+e+" 不正在房间中，或者没有发布媒体"),o=Object.assign(s.CONSTANT_ERROR.invalidOperation,{reason:e+" 不正在房间中，或者没有发布媒体"})):(t.logger.log("NErtc::subscribe 不正在房间中，请勿调用！"),o=Object.assign(s.CONSTANT_ERROR.invalidOperation,{reason:"在join之前，不允许执行unpublish操作"})),!o){r.next=5;break}return t.apiEventReport("setFunction",{name:"subscribe",oper:u.toString(),value:JSON.stringify(o,null," ")}),r.abrupt("return",Promise.reject(o));case 5:return u=e,t.logger.log("NErtc::subscribe 订阅 uid: "+u+", mediaType: "+n),"string"==typeof e&&(u=new d(e),t.logger.log("NErtc::subscribe 订阅媒体 remoteUid: ",u)),r.prev=8,t.logger.log("NErtc::subscribe 开始发送sub消息"),(a=t._info.userlist.get(u.toString())).subscribed[n]=!0,t._info.userlist.set(u.toString(),a),r.next=15,t._wsController.subscribe(u,n);case 15:return t.logger.log("NErtc::subscribe 订阅 "+u+" 的 "+n+"媒体的请求, 发送成功"),c=a.url,t.logger.log("user: ",a),"screenShare"===n?c=a.screen_url:"slaveAudio"===n&&(c=a.slaveaudio_url||a.sa_url),t.logger.log("NErtc::subscribe 订阅 "+a.uid+" 的 "+n+" 成功: "+c),t.apiEventReport("setFunction",{name:"subscribe",oper:u.toString(),value:JSON.stringify({uid:d.isBigNumber(e)?e.toString():e,url:c},null," ")}),r.abrupt("return",Promise.resolve({uid:d.isBigNumber(e)?e.toString():e,url:c}));case 24:return r.prev=24,r.t0=r.catch(8),t.logger.log("NErtc::subscribe 订阅 "+user.uid+" 的 "+n+" 失败"),t.logger.error("NErtc::subscribe 订阅失败的具体原因: ",r.t0),user.subscribed[n]=!1,t.apiEventReport("setFunction",{name:"subscribe",oper:u.toString(),value:JSON.stringify({uid:d.isBigNumber(e)?e.toString():e,code:r.t0.code,reason:r.t0.errMsg},null," ")}),r.abrupt("return",Promise.reject(r.t0));case 31:case"end":return r.stop()}},i,t,[[8,24]])}))()},unsubscribe:function(e){var t=this,n=arguments.length>1&&void 0!==arguments[1]?arguments[1]:"";return (0, i.default)(r.default.mark(function i(){var o,u;return r.default.wrap(function(r){for(;;)switch(r.prev=r.next){case 0:if(o=null,t._status.isInTheRoom?"audio"!==n&&"video"!==n&&"screenShare"!==n&&"slaveAudio"!==n?(t.logger.log("NErtc::unsubscribe mediaType参数错误"),o=Object.assign(s.CONSTANT_ERROR.invalidOperation,{reason:"unsubscribe接口mediaType参数错误"})):e&&t._info.userlist.get(e.toString())||(t.logger.log("NErtc::unsubscribe "+e+" 不正在房间中，或者没有发布媒体"),o=Object.assign(s.CONSTANT_ERROR.invalidOperation,{reason:e+" 不正在房间中，或者没有发布媒体"})):(t.logger.log("NErtc::unsubscribe 不正在房间中，请勿调用！"),o=Object.assign(s.CONSTANT_ERROR.invalidOperation,{reason:"在join之前，不允许执行unpublish操作"})),!o){r.next=5;break}return t.apiEventReport("setFunction",{name:"unsubscribe",oper:e.toString(),value:JSON.stringify(o,null," ")}),r.abrupt("return",Promise.reject(o));case 5:return "string"==typeof e&&(e=new d(e)),t.logger.log("NErtc::unsubscribe 停止订阅 "+e+" 的 "+n+" 媒体"),(u=t._info.userlist.get(e.toString())).subscribed[n]=!1,t._info.userlist.set(e.toString(),u),r.prev=10,r.next=13,t._wsController.unsubscribe(e,n);case 13:t.apiEventReport("setFunction",{name:"unsubscribe",oper:e.toString(),value:JSON.stringify({uid:e,mediaType:n},null," ")}),r.next=18;break;case 16:r.prev=16,r.t0=r.catch(10);case 18:case"end":return r.stop()}},i,t,[[10,16]])}))()},mute:function(){var e=this,t=arguments.length>0&&void 0!==arguments[0]?arguments[0]:"",n=arguments.length>1&&void 0!==arguments[1]?arguments[1]:0;return (0, i.default)(r.default.mark(function i(){return r.default.wrap(function(r){for(;;)switch(r.prev=r.next){case 0:if(e._status.isInTheRoom){r.next=5;break}return e.logger.log("NErtc::mute 不正在房间中，请勿调用！"),r.abrupt("return",Promise.reject(Object.assign(s.CONSTANT_ERROR.invalidOperation,{reason:"在join之前，不允许执行mute操作"})));case 5:if("audio"===t||"video"===t){r.next=8;break}return e.logger.log("NErtc::mute mediaType参数错误"),r.abrupt("return",Promise.reject(Object.assign(s.CONSTANT_ERROR.invalidOperation,{reason:"mute接口mediaType参数错误"})));case 8:if(e.logger.log("NErtc::mute: ",t),r.prev=9,!t){r.next=15;break}return r.next=13,e._wsController.mute(n,t);case 13:r.next=19;break;case 15:return r.next=17,e._wsController.mute(n,"audio");case 17:return r.next=19,e._wsController.mute(n,"video");case 19:return e.apiEventReport("setFunction",{name:"mute",oper:t,value:"success"}),r.abrupt("return");case 23:return r.prev=23,r.t0=r.catch(9),r.abrupt("return",Promise.reject(r.t0));case 26:case"end":return r.stop()}},i,e,[[9,23]])}))()},unmute:function(){var e=this,t=arguments.length>0&&void 0!==arguments[0]?arguments[0]:"",n=arguments.length>1&&void 0!==arguments[1]?arguments[1]:0;return (0, i.default)(r.default.mark(function i(){return r.default.wrap(function(r){for(;;)switch(r.prev=r.next){case 0:if(e._status.isInTheRoom){r.next=4;break}e.logger.log("NErtc::unmute 不正在房间中，请勿调用！"),r.next=7;break;case 4:if("audio"===t||"video"===t){r.next=7;break}return e.logger.log("NErtc::unmute mediaType参数错误"),r.abrupt("return",Promise.reject(Object.assign(s.CONSTANT_ERROR.invalidOperation,{reason:"unmute接口mediaType参数错误"})));case 7:if(e.logger.log("NErtc::unmute: ",t),r.prev=8,!t){r.next=14;break}return r.next=12,e._wsController.unmute(n,t);case 12:r.next=18;break;case 14:return r.next=16,e._wsController.unmute(n,"audio");case 16:return r.next=18,e._wsController.unmute(n,"video");case 18:return e.apiEventReport("setFunction",{name:"unmute",oper:t,value:"success"}),r.abrupt("return");case 22:return r.prev=22,r.t0=r.catch(8),r.abrupt("return",Promise.reject(r.t0));case 25:case"end":return r.stop()}},i,e,[[8,22]])}))()},dataReporter:function(){var e=arguments.length>0&&void 0!==arguments[0]?arguments[0]:"push",t=arguments[1],n=arguments[2];this.apiEventReport("setFunction",{name:t,oper:e,value:JSON.stringify(n,null," ")});},apiEventReport:function(){var e=arguments.length>0&&void 0!==arguments[0]?arguments[0]:"setFunction",t=arguments[1];if(e){var n=new u.default({channelInfo:Object.assign(this._info,this._status)});n[e](Object.assign({uid:""+this._info.uid,cid:""+this._info.cid,time:Date.now()},t)),n.send(),n=null;}},leave:function(){return this._status.isInTheRoom?(this.apiEventReport("setLogout",{reason:0}),this._updateStatus({isInTheRoom:!1}),this._dataReporter.sendStatistics(),this._resetStatus(),this._wsController.leaveChannel()):(this.logger.log("当前不在房间中"),Promise.resolve())},addTasks:function(e){var t=this;return (0, i.default)(r.default.mark(function n(){var i,u,a,c,f,d,p;return r.default.wrap(function(n){for(;;)switch(n.prev=n.next){case 0:if(t.logger.log("增加互动直播推流任务, options: ",JSON.stringify(e)),i=e.rtmpTasks,u=void 0===i?[]:i,t._status.isInTheRoom){n.next=6;break}return n.abrupt("return",Promise.reject(Object.assign(s.CONSTANT_ERROR.invalidOperation,{reason:"addTasks: 请先加入房间"})));case 6:if("audience"!==t._status.role){n.next=10;break}return n.abrupt("return",Promise.reject(Object.assign(s.CONSTANT_ERROR.invalidOperation,{reason:"addTasks: 观众不允许进行直播推流操作"})));case 10:if(u&&Array.isArray(u)&&u.length){n.next=13;break}return t.logger.error("添加推流任务失败: 参数格式错误，rtmpTasks为空，或者该数组长度为空"),n.abrupt("return",Promise.reject(Object.assign(s.CONSTANT_ERROR.invalidOperation,{reason:"addTasks: 接口参数错误"})));case 13:a=l.miniG2.roomsTaskUrl,t.logger.log("缺省roomsTaskUrl: ",a),t._status.roomServer&&(a=t._status.roomServer+"/",t.logger.warn("私有化配置roomsTaskUrl: ",a)),a=""+a+t._info.cid+"/tasks",c=t._info.uid,f=0;case 19:if(!(f<u.length)){n.next=43;break}return u[f].hostUid=c-0,u[f].version=1,t.logger.log("rtmpTask: ",JSON.stringify(u[f])),d=u[f].layout,n.prev=24,n.next=27,o.default.post({version:1,taskId:u[f].taskId+"",streamUrl:u[f].streamUrl,record:u[f].record,hostUid:u[f].hostUid,layout:d,config:u[f].config,extraInfo:u[f].extraInfo},{url:a},{"content-type":"application/json;charset=utf-8",Token:t._info.turnToken});case 27:if(200!==(p=n.sent).code){n.next=32;break}t.logger.log("添加推流任务完成"),n.next=34;break;case 32:return t.logger.error("添加推流任务失败: ",p),n.abrupt("return",Promise.reject(Object.assign(s.CONSTANT_ERROR.addTasksFailed,{reason:"addTasks: "+(p.reason||p.errmsg)})));case 34:n.next=40;break;case 36:return n.prev=36,n.t0=n.catch(24),t.logger.error("addTasks 发生错误: ",n.t0.name,n.t0.message,n.t0),n.abrupt("return",Promise.reject(s.CONSTANT_ERROR.addTasksFailed));case 40:f++,n.next=19;break;case 43:case"end":return n.stop()}},n,t,[[24,36]])}))()},deleteTasks:function(e){var t=this;return (0, i.default)(r.default.mark(function n(){var i,u,a,c,f;return r.default.wrap(function(n){for(;;)switch(n.prev=n.next){case 0:if(t.logger.log("删除互动直播推流任务, options: ",JSON.stringify(e)),i=e.taskIds,u=void 0===i?[]:i,t._status.isInTheRoom){n.next=6;break}return n.abrupt("return",Promise.reject(Object.assign(s.CONSTANT_ERROR.invalidOperation,{reason:"deleteTasks: 请先加入房间"})));case 6:if("audience"!==t._status.role){n.next=10;break}return n.abrupt("return",Promise.reject(Object.assign(s.CONSTANT_ERROR.invalidOperation,{reason:"deleteTasks: 观众不允许进行直播推流操作"})));case 10:if(u&&Array.isArray(u)&&u.length){n.next=13;break}return t.logger.error("deleteTasks: 参数格式错误，taskIds为空，或者该数组长度为空"),n.abrupt("return",Promise.reject(Object.assign(s.CONSTANT_ERROR.invalidOperation,{reason:"deleteTasks: 接口参数错误"})));case 13:a=l.miniG2.roomsTaskUrl,t.logger.log("缺省roomsTaskUrl: ",a),t._status.roomServer&&(a=t._status.roomServer+"/",t.logger.warn("私有化配置roomsTaskUrl: ",a)),a=""+a+t._info.cid+"/tasks/delete",c=0;case 18:if(!(c<u.length)){n.next=39;break}return t.logger.log("deleteTasks: ",u[c]),n.prev=20,n.next=23,o.default.post({taskId:u[c]+""},{url:a},{"content-type":"application/json;charset=utf-8",Token:t._info.turnToken});case 23:if(200!==(f=n.sent).code){n.next=28;break}t.logger.log("删除推流任务完成"),n.next=30;break;case 28:return t.logger.log("删除推流任务请求失败:",JSON.stringify(f)),n.abrupt("return",Promise.reject(Object.assign(s.CONSTANT_ERROR.deleteTasksFailed,{reason:"deleteTasks: "+(f.reason||f.errmsg)})));case 30:n.next=36;break;case 32:return n.prev=32,n.t0=n.catch(20),t.logger.error("deleteTasks发生错误: d",n.t0.name,n.t0.message,n.t0),n.abrupt("return",Promise.reject(s.CONSTANT_ERROR.deleteTasksFailed));case 36:c++,n.next=18;break;case 39:return n.abrupt("return");case 40:case"end":return n.stop()}},n,t,[[20,32]])}))()},updateTasks:function(e){var t=this;return (0, i.default)(r.default.mark(function n(){var i,u,a,c,f,d;return r.default.wrap(function(n){for(;;)switch(n.prev=n.next){case 0:if(t.logger.log("更新互动直播推流任务, options: ",JSON.stringify(e)),i=e.rtmpTasks,u=void 0===i?[]:i,t._status.isInTheRoom){n.next=6;break}return n.abrupt("return",Promise.reject(Object.assign(s.CONSTANT_ERROR.invalidOperation,{reason:"updateTasks: 请先加入房间"})));case 6:if("audience"!==t._status.role){n.next=10;break}return n.abrupt("return",Promise.reject(Object.assign(s.CONSTANT_ERROR.invalidOperation,{reason:"updateTasks: 观众不允许进行直播推流操作"})));case 10:if(u&&Array.isArray(u)&&u.length){n.next=13;break}return t.logger.error("updateTasks: 参数格式错误，rtmpTasks为空，或者该数组长度为空"),n.abrupt("return",Promise.reject(Object.assign(s.CONSTANT_ERROR.invalidOperation,{reason:"updateTasks: 接口参数错误"})));case 13:a=l.miniG2.roomsTaskUrl,t.logger.log("缺省roomsTaskUrl: ",a),t._status.roomServer&&(a=t._status.roomServer+"/",t.logger.warn("私有化配置roomsTaskUrl: ",a)),a=""+a+t._info.cid+"/task/update",t._info.uid,c=0;case 19:if(!(c<u.length)){n.next=41;break}return f=u[c].layout,t.logger.log("rtmpTask: ",JSON.stringify(u[c])),n.prev=22,n.next=25,o.default.post({version:1,taskId:u[c].taskId+"",streamUrl:u[c].streamUrl,record:u[c].record,hostUid:u[c].hostUid,layout:f,config:u[c].config,extraInfo:u[c].extraInfo},{url:a},{"content-type":"application/json;charset=utf-8",Token:t._info.turnToken});case 25:if(200!==(d=n.sent).code){n.next=30;break}t.logger.log("更新推流任务完成"),n.next=32;break;case 30:return t.logger.error("更新推流任务失败：",JSON.stringify(d)),n.abrupt("return",Promise.reject(Object.assign(s.CONSTANT_ERROR.updateTasksFailed,{reason:"updateTasks: "+(d.reason||d.errmsg)})));case 32:n.next=38;break;case 34:return n.prev=34,n.t0=n.catch(22),t.logger.error("updateTasks 发生错误: ",n.t0.name,n.t0.message,n.t0),n.abrupt("return",Promise.reject(s.CONSTANT_ERROR.updateTasksFailed));case 38:c++,n.next=19;break;case 41:case"end":return n.stop()}},n,t,[[22,34]])}))()},directCall:function(e){var t=this;return (0, i.default)(r.default.mark(function n(){var i,u,a,c,l,f,d;return r.default.wrap(function(n){for(;;)switch(n.prev=n.next){case 0:if(t.logger.log("[directCall] directCall() [parm: "+JSON.stringify(e,null," ")+"]"),i=e.appKey,u=e.token,a=e.callee,c=e.didNumber,l=e.channelName,e.callType,f=e.traceId,d=void 0===f?"":f,i&&u&&l&&a){n.next=4;break}return n.abrupt("return",Promise.reject(Object.assign(s.CONSTANT_ERROR.invalidOperation,{reason:"directCall: 参数缺省, appKey token channelName callee 为必须参数"})));case 4:return n.prev=4,n.next=7,t.getLinkUrl();case 7:return n.next=9,t._initDirectCallSignalling();case 9:return t.logger.log("[directCall] directCall() [ connect to the link server done, and start directCall]"),t._info.calloutSessionId=o.default.strUuid(),n.next=13,t._directCallSignalling.directCall({appKey:i,token:u,callee:[a],didNumber:c,sessionId:o.default.strUuid(),uid:l,channelName:l,callType:0,traceId:d});case 13:n.next=21;break;case 15:return n.prev=15,n.t0=n.catch(4),t.logger.error("[directCall] directCall() [connect to the link server, error: %o]",n.t0),t.leave(),t._directCallSignalling&&(t.logger.log("[directCall] hangupDirectCall() [signalling hangup]"),t._directCallSignalling.hangup({}),t._directCallSignalling.destroy(),t._directCallSignalling=null),n.abrupt("return",Promise.reject(n.t0));case 21:case"end":return n.stop()}},n,t,[[4,15]])}))()},hangupDirectCall:function(){var e=this;return (0, i.default)(r.default.mark(function t(){return r.default.wrap(function(t){for(;;)switch(t.prev=t.next){case 0:if(e.logger.log("[directCall] hangupDirectCall()"),t.prev=1,!e._rtcAbility){t.next=7;break}return e.logger.log("[bye] bye() [rtcAbility destroy]"),t.next=6,e._rtcAbility.destroy();case 6:e._rtcAbility=null;case 7:if(!e._directCallSignalling){t.next=11;break}return e.logger.log("[directCall] hangupDirectCall() [signalling hangup]"),t.next=11,e._directCallSignalling.hangup({});case 11:e.logger.log("[directCall] hangupDirectCall() [done]"),t.next=18;break;case 14:return t.prev=14,t.t0=t.catch(1),e.logger.error("[bye] hangupDirectCall() failed: ",t.t0),t.abrupt("return",Promise.reject(t.t0));case 18:case"end":return t.stop()}},t,e,[[1,14]])}))()},switchMode:function(e){return o.default.isNumber(e)?(this._dataReporter.updateStatistics({miniapp_mode:e}),this.logger.log("设置推流模式: ",e),this._wsController.switchMode(e)):Promise.reject("switchMode: 入参类型必须为Number")},getUploadUserList:function(){return this._wsController._websocket.getUploadUserList()},_generateJoinParam:function(e){var t={},n=this._status.createChannelResponse;return t.cid=parseInt(n.cid),t.uid=n.uid,t.token=n.token,t.mode=parseInt(e.mode),t.scene=n.scene,t.liveEnable=e.liveEnable?s.LIVE_ENABLE.LIVE_ENABLE_OPEN:s.LIVE_ENABLE.LIVE_ENABLE_CLOSE,t.role=e.role?s.ROLE_FOR_MEETING.ROLE_AUDIENCE:s.ROLE_FOR_MEETING.ROLE_HOST,t.webrtc=1,t.address=e.address||"wss://"+n.ips.wechatapparray[0],t.edgeAddr=e.edgeAddr||n.ips.turnaddrs[0][0],t.recordType=e.recordType?e.recordType:s.RECORD_TYPE.RECORD_TYPE_MIX_SINGLE,t.recordAudio=e.recordAudio?s.RECORD_AUDIO.RECORD_AUDIO_OPEN:s.RECORD_AUDIO.RECORD_AUDIO_CLOSE,t.recordVideo=e.recordVideo?s.RECORD_VIDEO.RECORD_VIDEO_OPEN:s.RECORD_VIDEO.RECORD_VIDEO_CLOSE,t.isHostSpeaker=e.isHostSpeaker?1:0,this.logger.log("NErtc::joinChannel",t),t},_getLink:function(){return this._wsController._websocket}};t.default=p,e.exports=t.default;},function(e,t,n){Object.defineProperty(t,"__esModule",{value:!0});var r=s(n(4)),i=s(n(5)),o=s(n(65));function s(e){return e&&e.__esModule?e:{default:e}}var u=n(44).version,a=function(){function e(t){(0, r.default)(this,e),this.channelInfo=t.channelInfo||{},this.cid=""+this.channelInfo.cid,this.uid=""+this.channelInfo.uid;var n=this.channelInfo.startSessionTime||Date.now();this.time=this.channelInfo.clientNtpTime-this.channelInfo.T4,this.common={ver:"2.0",sdk_type:"nrtc2",session_id:(0, o.default)(this.cid+":"+this.uid+":"+n),app_key:this.channelInfo.appkey||""},this.platform="mini",this.model=this.channelInfo.runtimeEnvironment||"mini",this.event=[],this.api=null,this.heartbeat=null;}return (0, i.default)(e,[{key:"addEvent",value:function(e){return -1==this.event.indexOf(e)&&this.event.push(e),this}},{key:"updateCommon",value:function(e){return Object.assign(this.common,e),this}},{key:"setEvent",value:function(e,t){this.addEvent(e),this[e]=t;}},{key:"setHeartbeat",value:function(e){var t=this,n=e.uid,r=e.cid,i=e.sys,o=e.tx,s=e.rx;this.heartbeat={uid:n,cid:r,sys:i,tx:o,rx:s},this.api=this.adapterRef.apiEvents.length?this.adapterRef.apiEvents:this.adapterRef.apiEvent;var u={apiEvent:[]};for(var a in this.api)this.api[a].length&&this.api[a].forEach(function(e){e.uid=t.uid-0,e.cid=t.cid-0;}),u.apiEvent=u.apiEvent.concat(this.api[a]);return this.api=null,this.api=u.apiEvent.length?u:null,this.adapterRef.apiEvents={},this.adapterRef.apiEvent={},this}},{key:"setLogin",value:function(e){var t=e.uid,n=e.cid,r=e.sdk_ver,i=void 0===r?u:r,o=(e.platform,e.app_key),s=void 0===o?this.common.app_key:o,a=e.meeting_mode,c=void 0===a?1:a,l=e.a_record,f=e.v_record,d=e.record_type,p=e.host_speaker,h=e.server_ip,g=e.result,_=e.time,m=e.signal_time_elapsed,v=e.time_elapsed;this.addEvent("login"),_=this.time+_,this.login={uid:t,cid:n,sdk_ver:i,platform:this.platform,model:this.model,app_key:s,meeting_mode:c,a_record:l,v_record:f,record_type:d,host_speaker:p,server_ip:h,result:g,time:_,signal_time_elapsed:m,time_elapsed:v};}},{key:"setRelogin",value:function(e){var t=e.uid,n=e.cid,r=e.meeting_mode,i=void 0===r?1:r,o=e.a_record,s=e.v_record,u=e.record_type,a=e.host_speaker,c=e.server_ip,l=e.result,f=e.time,d=e.reason;this.addEvent("relogin"),f=this.time+f,this.relogin={uid:t,cid:n,platform:this.platform,meeting_mode:i,a_record:o,v_record:s,record_type:u,host_speaker:a,server_ip:c,result:l,time:f,reason:d};}},{key:"setLogout",value:function(e){var t=e.uid,n=e.cid,r=e.time,i=e.reason;this.addEvent("logout"),r=this.time+r,this.logout={uid:t,cid:n,time:r,reason:i};}},{key:"setDisconnect",value:function(e){var t=e.uid,n=e.cid,r=e.reason,i=e.time;this.addEvent("disconnect"),i=this.time+i,this.disconnect={uid:t,cid:n,reason:r,time:i};}},{key:"setFunction",value:function(e){var t=e.uid,n=e.cid,r=e.oper,i=e.value,o=e.time,s=e.name;this.addEvent("function"),o=this.time+o,this.function={uid:t,cid:n,oper:r,value:i,time:o,name:s};}},{key:"reset",value:function(){this.event=[],this.api=null,this.heartbeat=null;}},{key:"send",value:function(e){var t=this,n={common:this.common};if(e||(e=this.event||null),this.heartbeat&&(n.heartbeat=this.heartbeat,this.api&&(n.event=this.api)),e)e.length&&(n.event=e.reduce(function(e,n){return e[n]=t[n],e},{}));else if(!this.heartbeat)return this;var r="https://statistic.live.126.net/statics/report/common/form";this.channelInfo.statisticsServer&&(r=this.channelInfo.statisticsServer);var i=this;if("mini"===this.model||"wechat"===this.model)wx.request({method:"post",url:r,data:n,header:{"content-type":"application/json",sdktype:this.common.sdk_type,appkey:this.common.app_key,platform:this.platform,sdkver:u},complete:function(){"function"==typeof i.reset&&i.reset();}});else {if("qq"!==this.model)throw Error("FunctionReport 不支持的平台");qq.request({method:"post",url:r,data:n,header:{"content-type":"application/json",sdktype:this.common.sdk_type,appkey:this.common.app_key,platform:this.platform,sdkver:u},complete:function(){"function"==typeof i.reset&&i.reset();}});}return this}}]),e}();t.default=a,e.exports=t.default;},function(e,t){var n,r;n="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/",r={rotl:function(e,t){return e<<t|e>>>32-t},rotr:function(e,t){return e<<32-t|e>>>t},endian:function(e){if(e.constructor==Number)return 16711935&r.rotl(e,8)|4278255360&r.rotl(e,24);for(var t=0;t<e.length;t++)e[t]=r.endian(e[t]);return e},randomBytes:function(e){for(var t=[];e>0;e--)t.push(Math.floor(256*Math.random()));return t},bytesToWords:function(e){for(var t=[],n=0,r=0;n<e.length;n++,r+=8)t[r>>>5]|=e[n]<<24-r%32;return t},wordsToBytes:function(e){for(var t=[],n=0;n<32*e.length;n+=8)t.push(e[n>>>5]>>>24-n%32&255);return t},bytesToHex:function(e){for(var t=[],n=0;n<e.length;n++)t.push((e[n]>>>4).toString(16)),t.push((15&e[n]).toString(16));return t.join("")},hexToBytes:function(e){for(var t=[],n=0;n<e.length;n+=2)t.push(parseInt(e.substr(n,2),16));return t},bytesToBase64:function(e){for(var t=[],r=0;r<e.length;r+=3)for(var i=e[r]<<16|e[r+1]<<8|e[r+2],o=0;o<4;o++)8*r+6*o<=8*e.length?t.push(n.charAt(i>>>6*(3-o)&63)):t.push("=");return t.join("")},base64ToBytes:function(e){e=e.replace(/[^A-Z0-9+\/]/gi,"");for(var t=[],r=0,i=0;r<e.length;i=++r%4)0!=i&&t.push((n.indexOf(e.charAt(r-1))&Math.pow(2,-2*i+8)-1)<<2*i|n.indexOf(e.charAt(r))>>>6-2*i);return t}},e.exports=r;},function(e,t){function n(e){return !!e.constructor&&"function"==typeof e.constructor.isBuffer&&e.constructor.isBuffer(e)}
/*!
 * Determine if an object is a Buffer
 *
 * @author   Feross Aboukhadijeh <https://feross.org>
 * @license  MIT
 */
e.exports=function(e){return null!=e&&(n(e)||function(e){return "function"==typeof e.readFloatLE&&"function"==typeof e.slice&&n(e.slice(0,0))}(e)||!!e._isBuffer)};}]);
});

var NERTC = unwrapExports(NERTC_Miniapp_SDK_v4_6_10);

var RTCController = /** @class */ (function (_super) {
    __extends(RTCController, _super);
    function RTCController(_a) {
        var appKey = _a.appKey, rtcConfig = _a.rtcConfig, kitName = _a.kitName, kitVersion = _a.kitVersion, _b = _a.debug, debug = _b === void 0 ? true : _b;
        var _this = _super.call(this) || this;
        _this.remoteStreams = []; // 远端流地址
        _this._rtcConfig = {};
        _this._inTheRoom = false;
        _this._rtcSDK = NERTC;
        _this.client = _this._rtcSDK.Client({ appkey: appKey, debug: debug });
        _this._log = debug
            ? c({
                appName: kitName,
                version: kitVersion,
                level: 'trace',
            }).log
            : function () {
                //
            };
        if (rtcConfig) {
            _this._rtcConfig = rtcConfig;
        }
        _this._addRtcEventListener();
        return _this;
    }
    RTCController.prototype.getChannelInfo = function () {
        var _a, _b, _c;
        return {
            cid: this.client._info.cid,
            channelName: (_a = this.client._info.joinChannelParam) === null || _a === void 0 ? void 0 : _a.channelName,
            uid: (_b = this.client._info.joinChannelParam) === null || _b === void 0 ? void 0 : _b.uid,
            token: (_c = this.client._info.joinChannelParam) === null || _c === void 0 ? void 0 : _c.token,
        };
    };
    RTCController.prototype.joinRTCChannel = function (options, getTokenCostTime) {
        var _a, _b, _c;
        return __awaiter(this, void 0, void 0, function () {
            var tokenCostTime, token, _d, res, error_1;
            return __generator(this, function (_e) {
                switch (_e.label) {
                    case 0:
                        _e.trys.push([0, 5, , 6]);
                        if (this._inTheRoom) {
                            this._log('joinRTCChannel in the room');
                            return [2 /*return*/];
                        }
                        tokenCostTime = Date.now();
                        if (!((_a = options.token) !== null && _a !== void 0)) return [3 /*break*/, 1];
                        _d = _a;
                        return [3 /*break*/, 3];
                    case 1: return [4 /*yield*/, ((_c = (_b = this._rtcConfig).getToken) === null || _c === void 0 ? void 0 : _c.call(_b, options))];
                    case 2:
                        _d = (_e.sent());
                        _e.label = 3;
                    case 3:
                        token = _d;
                        tokenCostTime = Date.now() - tokenCostTime;
                        getTokenCostTime === null || getTokenCostTime === void 0 ? void 0 : getTokenCostTime(tokenCostTime);
                        this._log('joinRTCChannel:', options);
                        return [4 /*yield*/, this.client.join(__assign(__assign({}, options), { token: token }))];
                    case 4:
                        res = _e.sent();
                        this._inTheRoom = true;
                        this._log('joinRTCChannel success: ', res);
                        return [3 /*break*/, 6];
                    case 5:
                        error_1 = _e.sent();
                        this._log('joinRTCChannel fail: ', error_1);
                        throw error_1;
                    case 6: return [2 /*return*/];
                }
            });
        });
    };
    RTCController.prototype.publishLocalStream = function (mediaType) {
        return __awaiter(this, void 0, void 0, function () {
            var error_2;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, this.client.publish(mediaType)];
                    case 1: return [2 /*return*/, _a.sent()];
                    case 2:
                        error_2 = _a.sent();
                        this._log('joinRTCChannel fail: ', error_2);
                        throw error_2;
                    case 3: return [2 /*return*/];
                }
            });
        });
    };
    RTCController.prototype.muteLocalVideo = function (mute) {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        if (!mute) return [3 /*break*/, 2];
                        return [4 /*yield*/, this.client.mute('video')];
                    case 1:
                        _a.sent();
                        return [3 /*break*/, 4];
                    case 2: return [4 /*yield*/, this.client.unmute('video')];
                    case 3:
                        _a.sent();
                        _a.label = 4;
                    case 4:
                        this._log('muteLocalVideo: ', mute);
                        return [2 /*return*/];
                }
            });
        });
    };
    RTCController.prototype.muteLocalAudio = function (mute) {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        if (!mute) return [3 /*break*/, 2];
                        return [4 /*yield*/, this.client.mute('audio')];
                    case 1:
                        _a.sent();
                        return [3 /*break*/, 4];
                    case 2: return [4 /*yield*/, this.client.unmute('audio')];
                    case 3:
                        _a.sent();
                        _a.label = 4;
                    case 4:
                        this._log('muteLocalAudio: ', mute);
                        return [2 /*return*/];
                }
            });
        });
    };
    RTCController.prototype.leaveRTCChannel = function () {
        return __awaiter(this, void 0, void 0, function () {
            var _a, error_3;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        _b.trys.push([0, 3, , 4]);
                        _a = this._inTheRoom;
                        if (!_a) return [3 /*break*/, 2];
                        return [4 /*yield*/, this.client.leave()];
                    case 1:
                        _a = (_b.sent());
                        _b.label = 2;
                    case 2:
                        this._inTheRoom = false;
                        this.resetState();
                        return [3 /*break*/, 4];
                    case 3:
                        error_3 = _b.sent();
                        this._log('leaveRTCChannel fail: ', error_3);
                        throw error_3;
                    case 4: return [2 /*return*/];
                }
            });
        });
    };
    RTCController.prototype.resetState = function () {
        this._log('rtcController resetState');
    };
    RTCController.prototype.destroy = function () {
        this.leaveRTCChannel();
        // this.resetState()
    };
    /**
     * 新增流，如果以存在，则更新流
     * @param stream
     */
    RTCController.prototype._addStream = function (stream) {
        return __awaiter(this, void 0, void 0, function () {
            var uid, mediaType, url, remoteStream;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        uid = stream.uid, mediaType = stream.mediaType;
                        return [4 /*yield*/, this.client.subscribe(uid, mediaType)];
                    case 1:
                        url = (_a.sent()).url;
                        remoteStream = this.remoteStreams.find(function (item) { return item.uid === uid; });
                        if (remoteStream) {
                            this._log('stream-added：订阅的流已存在，更新流');
                            remoteStream.url = url;
                        }
                        else {
                            this._log('stream-added：新增需要订阅的流');
                            this.remoteStreams.push({ uid: uid, url: url });
                        }
                        this.emit('streamSubscribed', { uid: uid, url: url });
                        return [2 /*return*/];
                }
            });
        });
    };
    RTCController.prototype._addRtcEventListener = function () {
        return __awaiter(this, void 0, void 0, function () {
            var _this = this;
            return __generator(this, function (_a) {
                this.client.on('clientJoin', function (evt) {
                    _this._log('clientJoin: ', evt);
                    _this.emit('clientJoin', evt.uid);
                });
                this.client.on('clientLeave', function (evt) {
                    _this._log('clientLeave: ', evt);
                    _this.emit('clientLeave', evt.uid);
                });
                this.client.on('stream-added', function (evt) { return __awaiter(_this, void 0, void 0, function () {
                    return __generator(this, function (_a) {
                        this._log('stream-added: ', evt);
                        this._addStream(evt);
                        return [2 /*return*/];
                    });
                }); });
                this.client.on('stream-removed', function (evt) {
                    _this._log('stream-removed: ', evt);
                });
                this.client.on('mute-video', function (evt) {
                    _this._log('mute-video: ', evt);
                    _this.emit('videoMuteOrUnmute', { mute: true, uid: evt.uid });
                });
                this.client.on('unmute-video', function (evt) {
                    _this._log('unmute-video: ', evt);
                    _this.emit('videoMuteOrUnmute', { mute: false, uid: evt.uid });
                });
                this.client.on('mute-audio', function (evt) {
                    _this._log('mute-audio: ', evt);
                });
                this.client.on('unmute-audio', function (evt) {
                    _this._log('unmute-audio: ', evt);
                });
                this.client.on('error', function (evt) {
                    _this._log('error: ', evt);
                    _this.emit('error', evt);
                });
                this.client.on('disconnect', function (evt) {
                    _this._log('disconnect: ', evt);
                });
                return [2 /*return*/];
            });
        });
    };
    return RTCController;
}(eventemitter3));

var name = "@xkit-yx/call-kit";
var author = "";
var description = "";
var files = [
	"dist",
	"assets",
	"miniprogram_dist"
];
var keywords = [
];
var license = "MIT";
var miniprogram = "miniprogram_dist";
var main = "dist/index.cjs.js";
var module$1 = "dist/index.esm.js";
var typings = "dist/types/index.d.ts";
var publishConfig = {
	access: "public"
};
var scripts = {
	dev: "rm -rf ./lib && rollup -c --environment DEV",
	build: "rollup -c"
};
var version = "1.8.1";
var dependencies = {
	"@xkit-yx/utils": "^0.4.4",
	eventemitter3: "^4.0.7",
	"nertc-web-sdk": "^4.6.25",
	"yunxin-log-debug": "^1.1.6"
};
var devDependencies = {
	"@rollup/plugin-json": "^4.1.0",
	"@rollup/plugin-node-resolve": "^10.0.0",
	rollup: "^2.33.1",
	"rollup-plugin-commonjs": "^10.1.0",
	"rollup-plugin-terser": "^7.0.2",
	"rollup-plugin-typescript2": "^0.31.2",
	typescript: "^4.0.3"
};
var pkg = {
	name: name,
	author: author,
	description: description,
	files: files,
	keywords: keywords,
	license: license,
	miniprogram: miniprogram,
	main: main,
	module: module$1,
	typings: typings,
	publishConfig: publishConfig,
	scripts: scripts,
	version: version,
	dependencies: dependencies,
	devDependencies: devDependencies
};

var WXNECall = /** @class */ (function (_super) {
    __extends(WXNECall, _super);
    function WXNECall(params) {
        var _this = this;
        var nim = params.nim, appKey = params.appKey, currentUserInfo = params.currentUserInfo, enableAutoJoinSignalChannel = params.enableAutoJoinSignalChannel, enableSwitchCallTypeConfirm = params.enableSwitchCallTypeConfirm, enableJoinRTCChannelWhenCall = params.enableJoinRTCChannelWhenCall, rtcConfig = params.rtcConfig, _a = params.debug, debug = _a === void 0 ? true : _a;
        _this = _super.call(this) || this;
        _this.costTimeEventTracking = {
            needPush: false,
            isCaller: false,
            callId: '',
            userAccId: '',
            token: 0,
            wait: 0,
            rtcJoin: 0,
            rtcVideo: 0,
            userAction: 0,
        };
        _this._userArr = [];
        _this._unusualTimeout = 15000;
        var kitName = 'NECall';
        var kitVersion = pkg.version;
        _this.signalController = new SignalController({
            nim: nim,
            kitName: kitName,
            enableAutoJoinSignalChannel: enableAutoJoinSignalChannel,
            kitVersion: kitVersion,
            debug: debug,
            uid: currentUserInfo.uid,
        });
        _this.rtcController = new RTCController({
            appKey: appKey,
            kitName: kitName,
            kitVersion: kitVersion,
            debug: debug,
            rtcConfig: rtcConfig,
        });
        _this._enableSwitchCallTypeConfirm = enableSwitchCallTypeConfirm !== null && enableSwitchCallTypeConfirm !== void 0 ? enableSwitchCallTypeConfirm : {
            video: false,
            audio: false,
        };
        _this._enableJoinRTCChannelWhenCall = enableJoinRTCChannelWhenCall !== null && enableJoinRTCChannelWhenCall !== void 0 ? enableJoinRTCChannelWhenCall : false;
        _this._currentUserInfo = currentUserInfo;
        _this._bindSignalControllerHooks();
        _this._handleRtcEvents();
        _this._handleWxEvents();
        return _this;
    }
    /**
     * 发起呼叫
     * @param params.accId 对方accId;
     * @param params.callType 呼叫类型;
     * @param params.callId 呼叫id;
     * @param params.signalChannelName 呼叫信道名称;
     * @param params.signalPushConfig 呼叫信道推送配置;
     * @param params.rtcChannelName rtc信道名称;
     * @param params.rtcTokenTtl rtcToken有效期;
     * @param params.enableOffline 是否允许离线;
     * @param params.extraInfo 附加信息;
     * @param params.globalExtraCopy 全局附加信息;
     * @returns
     */
    WXNECall.prototype.call = function (params) {
        var _a, _b;
        return __awaiter(this, void 0, void 0, function () {
            var channelInfo, uid, res;
            var _this = this;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0: return [4 /*yield*/, this.signalController.call(params)];
                    case 1:
                        channelInfo = _c.sent();
                        uid = (_b = (_a = channelInfo.members.find(function (item) { return item.accid === _this._currentUserInfo.accId; })) === null || _a === void 0 ? void 0 : _a.uid) !== null && _b !== void 0 ? _b : '';
                        this._callType = params.callType;
                        this._callId = channelInfo.attachExt.callId;
                        res = {
                            callId: channelInfo.attachExt.callId,
                            uid: uid,
                        };
                        return [2 /*return*/, res];
                }
            });
        });
    };
    /**
     * 接收呼叫
     * @param params.callId 呼叫id，非必填
     * @param params.enableOffline 是否接收离线消息;
     */
    WXNECall.prototype.accept = function (params) {
        var _a, _b;
        return __awaiter(this, void 0, void 0, function () {
            var channelInfo, uid, res;
            var _this = this;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0:
                        if (this.signalController.callStatus !== 2) {
                            throw new Error('当前不是接收状态');
                        }
                        return [4 /*yield*/, this.signalController.accept(params)];
                    case 1:
                        channelInfo = _c.sent();
                        uid = (_b = (_a = channelInfo.members.find(function (item) { return item.accid === _this._currentUserInfo.accId; })) === null || _a === void 0 ? void 0 : _a.uid) !== null && _b !== void 0 ? _b : '';
                        res = {
                            callId: channelInfo.attachExt.callId,
                            uid: uid,
                        };
                        return [2 /*return*/, res];
                }
            });
        });
    };
    /**
     * 拒绝呼叫，包含主叫取消，被叫拒绝（reason: 3，主叫接受到繁忙），通话中挂断。
     * @param params.callId 呼叫id
     * @param params.reason 拒绝原因
     * @param params.enableOffline 是否接收离线消息
     */
    WXNECall.prototype.hangup = function (params) {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        if (!(this.signalController.callStatus === 1)) return [3 /*break*/, 2];
                        return [4 /*yield*/, this.signalController.cancel(params)];
                    case 1:
                        _a.sent();
                        _a.label = 2;
                    case 2:
                        if (!(this.signalController.callStatus === 2)) return [3 /*break*/, 4];
                        return [4 /*yield*/, this.signalController.reject(params)];
                    case 3:
                        _a.sent();
                        _a.label = 4;
                    case 4:
                        if (!(this.signalController.callStatus === 3)) return [3 /*break*/, 6];
                        return [4 /*yield*/, this.signalController.hangup(params)];
                    case 5:
                        _a.sent();
                        _a.label = 6;
                    case 6: return [2 /*return*/];
                }
            });
        });
    };
    /**
     * 切换呼叫类型
     * @param params.callId 呼叫id
     * @param params.callType 呼叫类型
     * @param params.state  1: 邀请； 2：同意； 3：拒绝
     */
    WXNECall.prototype.switchCallType = function (params) {
        return __awaiter(this, void 0, void 0, function () {
            var needConfirm;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        if (!(params.state === 1)) return [3 /*break*/, 2];
                        needConfirm = (params.callType === '1' && this._enableSwitchCallTypeConfirm.audio) ||
                            (params.callType === '2' && this._enableSwitchCallTypeConfirm.video);
                        if (!!needConfirm) return [3 /*break*/, 2];
                        this.emit('onSwtichCallType', {
                            callId: params.callId || this._callId,
                            callType: params.callType,
                            state: 2,
                        });
                        return [4 /*yield*/, this.signalController.control({
                                callId: params.callId,
                                ext: {
                                    cid: 2,
                                    type: Number(params.callType),
                                },
                            })];
                    case 1:
                        _a.sent();
                        this._switchRTCCallType(params.callType);
                        _a.label = 2;
                    case 2:
                        if (params.state === 2) {
                            this.emit('onSwtichCallType', {
                                callId: params.callId || this._callId,
                                callType: params.callType,
                                state: 2,
                            });
                            this._switchRTCCallType(params.callType);
                        }
                        return [4 /*yield*/, this.signalController.control({
                                callId: params.callId,
                                ext: {
                                    cid: 3,
                                    type: Number(params.callType),
                                    state: params.state,
                                },
                            })];
                    case 3:
                        _a.sent();
                        return [2 /*return*/];
                }
            });
        });
    };
    /**
     * 开关本地视频
     * @param enabled true: 开启； false: 关闭
     */
    WXNECall.prototype.enableLocalVideo = function (enabled) {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this.rtcController.muteLocalVideo(!enabled)];
                    case 1:
                        _a.sent();
                        return [2 /*return*/];
                }
            });
        });
    };
    /**
     * 开关本地音频
     * @param enabled true: 开启； false: 关闭
     */
    WXNECall.prototype.enableLocalAudio = function (enabled) {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this.rtcController.muteLocalAudio(!enabled)];
                    case 1:
                        _a.sent();
                        return [2 /*return*/];
                }
            });
        });
    };
    /**
     * 设置切换音视频的确认开关
     * @param params.audio true: 需要； false: 不需要
     * @param params.video true: 需要； false: 不需要
     */
    WXNECall.prototype.setEnableSwitchCallTypeConfirm = function (params) {
        var _a = params.video, video = _a === void 0 ? this._enableSwitchCallTypeConfirm.video : _a, _b = params.audio, audio = _b === void 0 ? this._enableSwitchCallTypeConfirm.audio : _b;
        this._enableSwitchCallTypeConfirm = { video: video, audio: audio };
    };
    /**
     * 设置提前加入RTC房间
     * @param enabled true: 开启； false: 关闭
     */
    WXNECall.prototype.setEnableJoinRTCChannelWhenCall = function (enabled) {
        this._enableJoinRTCChannelWhenCall = enabled;
    };
    /**
     * 设置超时时间
     * @param params.callTimeout 超时取消，单位：毫秒
     * @param params.rejectTimeout 超时挂断时间，单位：毫秒
     */
    WXNECall.prototype.setTimeout = function (params) {
        params.callTimeout &&
            (this.signalController.callTimeout = params.callTimeout);
        params.rejectTimeout &&
            (this.signalController.rejectTimeout = params.rejectTimeout);
    };
    /**
     * 根据accId获取rtc uid
     * @param accId 用户 im 的 accId
     */
    WXNECall.prototype.getUidByAccId = function (accId) {
        var _a;
        return (_a = this._userArr.find(function (item) { return item.accId === accId; })) === null || _a === void 0 ? void 0 : _a.uid;
    };
    /**
     * 重连，im 重连成功后调用
     */
    WXNECall.prototype.reconnect = function () {
        // 获取离线消息
        this.signalController.reconnect();
    };
    /**
     * 销毁
     */
    WXNECall.prototype.destroy = function () {
        this.rtcController.destroy();
        this.signalController.destroy();
    };
    WXNECall.prototype._switchRTCCallType = function (callType) {
        this._callType = callType;
        this.enableLocalVideo(callType === '2');
        this.enableLocalAudio(true);
    };
    WXNECall.prototype._rtcJoin = function (channelInfo) {
        return __awaiter(this, void 0, void 0, function () {
            var rtcChannelName, res;
            var _this = this;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        // 这里处理异常
                        this._unusualTimer = setTimeout(function () {
                            _this._handleCallEnd({ callId: _this._callId, reason: 8 });
                        }, this._unusualTimeout);
                        rtcChannelName = channelInfo.attachExt.channelName;
                        return [4 /*yield*/, this.rtcController.joinRTCChannel({
                                channelName: rtcChannelName,
                                uid: this._currentUserInfo.uid,
                                token: this._nertcToken,
                            })
                            // 在加入的过程中可能状态已经不对了
                        ];
                    case 1:
                        _a.sent();
                        // 在加入的过程中可能状态已经不对了
                        if (this.signalController.callStatus !== 3) {
                            this._handleClose();
                            return [2 /*return*/];
                        }
                        return [4 /*yield*/, this.rtcController.publishLocalStream()];
                    case 2:
                        res = _a.sent();
                        this.emit('onStreamPublish', res);
                        return [2 /*return*/];
                }
            });
        });
    };
    WXNECall.prototype._handleClose = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this.rtcController.leaveRTCChannel()];
                    case 1:
                        _a.sent();
                        return [2 /*return*/];
                }
            });
        });
    };
    WXNECall.prototype._syncCurrentUserInfoBySignalControllerMembers = function (members) {
        var _this = this;
        var member = members.find(function (member) { return member.accid === _this._currentUserInfo.accId; });
        if (member) {
            this._currentUserInfo.uid = member.uid;
        }
    };
    WXNECall.prototype._handleCallEnd = function (callEndInfo) {
        this._unusualTimer && clearTimeout(this._unusualTimer);
        this._unusualTimer = undefined;
        this.signalController.callStatus === 3 && this.signalController.hangup();
        this._handleClose();
        this.emit('onCallEnd', callEndInfo);
    };
    WXNECall.prototype._bindSignalControllerHooks = function () {
        var _this = this;
        this.signalController.on('afterSignalCallEx', function (value) { return __awaiter(_this, void 0, void 0, function () {
            var rtcChannelName;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        this._nertcToken = value.nertcToken;
                        this._syncCurrentUserInfoBySignalControllerMembers(value.members);
                        if (!this._enableJoinRTCChannelWhenCall) return [3 /*break*/, 2];
                        rtcChannelName = value.attachExt.channelName;
                        return [4 /*yield*/, this.rtcController.joinRTCChannel({
                                channelName: rtcChannelName,
                                uid: this._currentUserInfo.uid,
                                token: this._nertcToken,
                            })];
                    case 1:
                        _a.sent();
                        _a.label = 2;
                    case 2: return [2 /*return*/];
                }
            });
        }); });
        this.signalController.on('afterSignalAccept', function (value) { return __awaiter(_this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        this._syncCurrentUserInfoBySignalControllerMembers(value.members);
                        this._nertcToken = value.nertcToken;
                        this._userArr = value.members.map(function (item) { return ({
                            accId: item.accid,
                            uid: item.uid,
                        }); });
                        return [4 /*yield*/, this._rtcJoin(value)];
                    case 1:
                        _a.sent();
                        return [2 /*return*/];
                }
            });
        }); });
        this.signalController.on('afterSignalCancel', function (value) { return __awaiter(_this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                this._handleCallEnd({
                    callId: this._callId,
                    reason: value.reason,
                    exReason: 0,
                });
                return [2 /*return*/];
            });
        }); });
        this.signalController.on('afterSignalReject', function (value) { return __awaiter(_this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                this._handleCallEnd({
                    callId: this._callId,
                    reason: value.reason,
                    exReason: 2,
                });
                return [2 /*return*/];
            });
        }); });
        this.signalController.on('afterSignalHangup', function () { return __awaiter(_this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                this._handleCallEnd({
                    callId: this._callId,
                    reason: 0,
                    exReason: 4,
                });
                return [2 /*return*/];
            });
        }); });
        this.signalController.on('whenSignalCancel', function (value) { return __awaiter(_this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                this._handleCallEnd({
                    callId: value.callId,
                    reason: 0,
                    exReason: 1,
                });
                return [2 /*return*/];
            });
        }); });
        this.signalController.on('whenSignalReject', function (value) { return __awaiter(_this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                this._handleCallEnd({
                    callId: this._callId,
                    reason: value.reason,
                    exReason: 3,
                });
                return [2 /*return*/];
            });
        }); });
        this.signalController.on('whenSignalAccept', function (value) { return __awaiter(_this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        this._userArr = value.members.map(function (item) { return ({
                            accId: item.accid,
                            uid: item.uid,
                        }); });
                        return [4 /*yield*/, this._rtcJoin(value)];
                    case 1:
                        _a.sent();
                        return [2 /*return*/];
                }
            });
        }); });
        this.signalController.on('whenSignalInvite', function (value) { return __awaiter(_this, void 0, void 0, function () {
            var callerInfo, inviterInfo;
            var _a, _b;
            return __generator(this, function (_c) {
                this._callType = value.type;
                this._syncCurrentUserInfoBySignalControllerMembers(value.members);
                callerInfo = {
                    accId: value.callerId,
                    uid: (_a = value.members.find(function (item) { return item.accid === value.callerId; })) === null || _a === void 0 ? void 0 : _a.uid,
                };
                inviterInfo = {
                    callId: value.attachExt.callId,
                    callerInfo: callerInfo,
                    calleeInfo: this._currentUserInfo,
                    callType: value.type,
                    exraInfo: value.attachExt.extraInfo || ((_b = value.attachExt) === null || _b === void 0 ? void 0 : _b._attachment),
                };
                this._callId = inviterInfo.callId;
                this.emit('onReceiveInvited', inviterInfo);
                return [2 /*return*/];
            });
        }); });
        this.signalController.on('whenSignalControl', function (value) { return __awaiter(_this, void 0, void 0, function () {
            var state, callType, needConfirm;
            var _a;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        if (!((value.cid === 3 || value.cid === 2) && value.type)) return [3 /*break*/, 4];
                        state = (_a = value.state) !== null && _a !== void 0 ? _a : 1;
                        callType = String(value.type);
                        if (callType === this._callType) {
                            return [2 /*return*/];
                        }
                        if (!(state === 1)) return [3 /*break*/, 3];
                        needConfirm = (callType === '1' && this._enableSwitchCallTypeConfirm.audio) ||
                            (callType === '2' && this._enableSwitchCallTypeConfirm.video);
                        if (!needConfirm) return [3 /*break*/, 1];
                        this.emit('onSwtichCallType', {
                            callId: this._callId,
                            callType: callType,
                            state: 1,
                        });
                        return [3 /*break*/, 3];
                    case 1:
                        this.emit('onSwtichCallType', {
                            callId: this._callId,
                            callType: callType,
                            state: 2,
                        });
                        this._switchRTCCallType(callType);
                        return [4 /*yield*/, this.signalController.control({
                                callId: this._callId,
                                ext: {
                                    cid: 3,
                                    type: Number(callType),
                                    state: 2,
                                },
                            })];
                    case 2:
                        _b.sent();
                        _b.label = 3;
                    case 3:
                        if (state === 2) {
                            this.emit('onSwtichCallType', {
                                callId: this._callId,
                                callType: callType,
                                state: 2,
                            });
                            this._switchRTCCallType(callType);
                        }
                        if (state === 3) {
                            this.emit('onSwtichCallType', {
                                callId: this._callId,
                                callType: callType,
                                state: 3,
                            });
                        }
                        _b.label = 4;
                    case 4: return [2 /*return*/];
                }
            });
        }); });
        this.signalController.on('whenSignalRoomClose', function () { return __awaiter(_this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                this._handleCallEnd({ callId: this._callId, reason: 0, exReason: 5 });
                return [2 /*return*/];
            });
        }); });
        this.signalController.on('whenSignalAcceptOtherClient', function () { return __awaiter(_this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                this._handleCallEnd({ callId: this._callId, reason: 9 });
                return [2 /*return*/];
            });
        }); });
        this.signalController.on('whenSignalRejectOtherClient', function () { return __awaiter(_this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                this._handleCallEnd({ callId: this._callId, reason: 10 });
                return [2 /*return*/];
            });
        }); });
        this.signalController.on('afterMessageSend', function (value) { return __awaiter(_this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                this.emit('onMessageSent', value);
                return [2 /*return*/];
            });
        }); });
    };
    WXNECall.prototype._handleRtcEvents = function () {
        var _this = this;
        this.rtcController.on('streamSubscribed', function (stream) {
            _this.emit('onStreamSubscribed', stream.url);
        });
        this.rtcController.on('clientJoin', function (stream) {
            _this._unusualTimer && clearTimeout(_this._unusualTimer);
            _this._unusualTimer = undefined;
            _this.emit('onCallConnected');
        });
        this.rtcController.on('clientLeave', function () {
            if (_this._unusualTimer)
                return;
            _this._unusualTimer = setTimeout(function () {
                _this._handleCallEnd({ callId: _this._callId, reason: 0 });
            }, _this._unusualTimeout);
        });
        this.rtcController.on('videoMuteOrUnmute', function (_a) {
            var mute = _a.mute;
            _this.emit('onVideoMuteOrUnmute', mute);
        });
        this.rtcController.on('error', function () {
            if (_this._unusualTimer)
                return;
            _this._unusualTimer = setTimeout(function () {
                _this._handleCallEnd({ callId: _this._callId, reason: 11 });
            }, _this._unusualTimeout);
        });
    };
    WXNECall.prototype._handleWxEvents = function () {
        var _this = this;
        var offlineTimer;
        var offlineTimeout = 30000;
        wx.onNetworkStatusChange(function (res) {
            if (!res.isConnected) {
                offlineTimer = setTimeout(function () {
                    if (_this.signalController.callStatus === 3) {
                        _this._handleCallEnd({ callId: _this._callId, reason: 12 });
                    }
                }, offlineTimeout);
            }
            else {
                offlineTimer && clearTimeout(offlineTimer);
                offlineTimer = undefined;
            }
        });
    };
    return WXNECall;
}(eventemitter3));

exports.NECall = WXNECall;
