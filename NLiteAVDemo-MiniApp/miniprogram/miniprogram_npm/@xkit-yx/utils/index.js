module.exports = (function() {
var __MODS__ = {};
var __DEFINE__ = function(modId, func, req) { var m = { exports: {}, _tempexports: {} }; __MODS__[modId] = { status: 0, func: func, req: req, m: m }; };
var __REQUIRE__ = function(modId, source) { if(!__MODS__[modId]) return require(source); if(!__MODS__[modId].status) { var m = __MODS__[modId].m; m._exports = m._tempexports; var desp = Object.getOwnPropertyDescriptor(m, "exports"); if (desp && desp.configurable) Object.defineProperty(m, "exports", { set: function (val) { if(typeof val === "object" && val !== m._exports) { m._exports.__proto__ = val.__proto__; Object.keys(val).forEach(function (k) { m._exports[k] = val[k]; }); } m._tempexports = val }, get: function () { return m._tempexports; } }); __MODS__[modId].status = 1; __MODS__[modId].func(__MODS__[modId].req, m, m.exports); } return __MODS__[modId].m.exports; };
var __REQUIRE_WILDCARD__ = function(obj) { if(obj && obj.__esModule) { return obj; } else { var newObj = {}; if(obj != null) { for(var k in obj) { if (Object.prototype.hasOwnProperty.call(obj, k)) newObj[k] = obj[k]; } } newObj.default = obj; return newObj; } };
var __REQUIRE_DEFAULT__ = function(obj) { return obj && obj.__esModule ? obj.default : obj; };
__DEFINE__(1689135971672, function(require, module, exports) {


Object.defineProperty(exports, '__esModule', { value: true });

var axios = require('axios');
var EventEmitter = require('eventemitter3');

function _interopDefaultLegacy (e) { return e && typeof e === 'object' && 'default' in e ? e : { 'default': e }; }

var axios__default = /*#__PURE__*/_interopDefaultLegacy(axios);
var EventEmitter__default = /*#__PURE__*/_interopDefaultLegacy(EventEmitter);

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

function __read(o, n) {
    var m = typeof Symbol === "function" && o[Symbol.iterator];
    if (!m) return o;
    var i = m.call(o), r, ar = [], e;
    try {
        while ((n === void 0 || n-- > 0) && !(r = i.next()).done) ar.push(r.value);
    }
    catch (error) { e = { error: error }; }
    finally {
        try {
            if (r && !r.done && (m = i["return"])) m.call(i);
        }
        finally { if (e) throw e.error; }
    }
    return ar;
}

function __spreadArray(to, from, pack) {
    if (pack || arguments.length === 2) for (var i = 0, l = from.length, ar; i < l; i++) {
        if (ar || !(i in from)) {
            if (!ar) ar = Array.prototype.slice.call(from, 0, i);
            ar[i] = from[i];
        }
    }
    return to.concat(ar || Array.prototype.slice.call(from));
}

var request$1 = function (_a) {
    var _b = _a.method, method = _b === void 0 ? 'POST' : _b, url = _a.url, data = _a.data, headers = _a.headers;
    return __awaiter(void 0, void 0, void 0, function () {
        var res, err_1;
        return __generator(this, function (_c) {
            switch (_c.label) {
                case 0:
                    _c.trys.push([0, 2, , 3]);
                    return [4 /*yield*/, axios__default["default"]({
                            method: method,
                            url: url,
                            data: data,
                            headers: headers,
                        })];
                case 1:
                    res = _c.sent();
                    if (res.data.code !== 200) {
                        return [2 /*return*/, Promise.reject(res.data)];
                    }
                    return [2 /*return*/, res.data];
                case 2:
                    err_1 = _c.sent();
                    return [2 /*return*/, Promise.reject(err_1)];
                case 3: return [2 /*return*/];
            }
        });
    });
};
var webRequestHelper = request$1;

var request = webRequestHelper;

var Storage = /** @class */ (function () {
    function Storage(type, salt) {
        this.store = new Map();
        this.type = 'memory';
        this.salt = '__salt__';
        type && (this.type = type);
        salt && (this.salt = salt);
    }
    Storage.prototype.get = function (key) {
        var value;
        switch (this.type) {
            case 'memory':
                return this.store.get(key);
            case 'localStorage':
                value = localStorage.getItem("".concat(this.salt).concat(key));
                if (value) {
                    return JSON.parse(value);
                }
                return value;
            case 'sessionStorage':
                value = sessionStorage.getItem("".concat(this.salt).concat(key));
                if (value) {
                    return JSON.parse(value);
                }
                return value;
        }
    };
    Storage.prototype.set = function (key, value) {
        switch (this.type) {
            case 'memory':
                this.store.set(key, value);
                break;
            case 'localStorage':
                localStorage.setItem("".concat(this.salt).concat(key), JSON.stringify(value));
                break;
            case 'sessionStorage':
                sessionStorage.setItem("".concat(this.salt).concat(key), JSON.stringify(value));
                break;
        }
    };
    Storage.prototype.remove = function (key) {
        switch (this.type) {
            case 'memory':
                this.store.delete(key);
                break;
            case 'localStorage':
                localStorage.removeItem("".concat(this.salt).concat(key));
                break;
            case 'sessionStorage':
                sessionStorage.removeItem("".concat(this.salt).concat(key));
                break;
        }
    };
    return Storage;
}());
var webStorage = Storage;

var index = webStorage;

var url = "https://statistic.live.126.net/statics/report/xkit/action";
var EventTracking = /** @class */ (function () {
    function EventTracking(_a) {
        var appKey = _a.appKey, version = _a.version, component = _a.component, nertcVersion = _a.nertcVersion, imVersion = _a.imVersion, _b = _a.platform, platform = _b === void 0 ? 'Web' : _b;
        this.platform = platform;
        this.appKey = appKey;
        this.version = version;
        this.component = component;
        this.nertcVersion = nertcVersion;
        this.imVersion = imVersion;
    }
    EventTracking.prototype.track = function (reportType, data) {
        return __awaiter(this, void 0, void 0, function () {
            var _a, appKey, version, component, nertcVersion, imVersion, platform, timeStamp;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0:
                        _a = this, appKey = _a.appKey, version = _a.version, component = _a.component, nertcVersion = _a.nertcVersion, imVersion = _a.imVersion, platform = _a.platform;
                        timeStamp = Date.now();
                        _c.label = 1;
                    case 1:
                        _c.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, request({
                                method: 'POST',
                                url: url,
                                data: {
                                    appKey: appKey,
                                    version: version,
                                    component: component,
                                    timeStamp: timeStamp,
                                    nertcVersion: nertcVersion,
                                    imVersion: imVersion,
                                    platform: platform,
                                    reportType: reportType,
                                    data: data,
                                },
                            })];
                    case 2:
                        _c.sent();
                        return [3 /*break*/, 4];
                    case 3:
                        _c.sent();
                        return [3 /*break*/, 4];
                    case 4: return [2 /*return*/];
                }
            });
        });
    };
    return EventTracking;
}());
var EventTracking$1 = EventTracking;

/**
 * 判断元素是否可见
 * 融合了 IntersectionObserver 与 visibilityChange 事件
 */
var VisibilityObserver = /** @class */ (function (_super) {
    __extends(VisibilityObserver, _super);
    // 入参说明参考：https://developer.mozilla.org/zh-CN/docs/Web/API/Intersection_Observer_API
    function VisibilityObserver(options) {
        var _this = _super.call(this) || this;
        _this.visibilityState = document.visibilityState;
        _this.entries = [];
        _this._visibilitychange = function () {
            _this.visibilityState = document.visibilityState;
            _this._trigger();
        };
        _this.intersectionObserver = new IntersectionObserver(_this._intersectionObserverHandler.bind(_this), options);
        document.addEventListener('visibilitychange', _this._visibilitychange);
        return _this;
    }
    VisibilityObserver.prototype.observe = function (target) {
        return this.intersectionObserver.observe(target);
    };
    VisibilityObserver.prototype.unobserve = function (target) {
        return this.intersectionObserver.unobserve(target);
    };
    VisibilityObserver.prototype.destroy = function () {
        this.intersectionObserver.disconnect();
        document.removeEventListener('visibilitychange', this._visibilitychange);
        this.entries = [];
    };
    VisibilityObserver.prototype._intersectionObserverHandler = function (entries, observer) {
        this.entries = entries;
        this._trigger();
    };
    VisibilityObserver.prototype._trigger = function () {
        var _this = this;
        this.entries.forEach(function (item) {
            if (_this.visibilityState !== 'visible' || item.intersectionRatio <= 0) {
                _this.emit('visibleChange', {
                    visible: false,
                    target: item.target,
                });
                return;
            }
            _this.emit('visibleChange', {
                visible: true,
                target: item.target,
            });
        });
    };
    return VisibilityObserver;
}(EventEmitter__default["default"]));
var VisibilityObserver$1 = VisibilityObserver;

var commonjsGlobal = typeof globalThis !== 'undefined' ? globalThis : typeof window !== 'undefined' ? window : typeof global !== 'undefined' ? global : typeof self !== 'undefined' ? self : {};

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

var log = loglevel;

function createLoggerDecorator(MODULE_NAME, logger) {
    return function (__, propKey, descriptor) {
        var method = descriptor.value;
        descriptor.value = function () {
            var args = [];
            for (var _i = 0; _i < arguments.length; _i++) {
                args[_i] = arguments[_i];
            }
            return __awaiter(this, void 0, void 0, function () {
                var methodName, res, err_1;
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0:
                            if (!logger) {
                                // @ts-ignore
                                logger = this.logger;
                            }
                            if (['log', 'error'].some(function (item) { return !logger[item]; })) {
                                console.warn('loggerDecorator warning: your logger is not complete');
                            }
                            methodName = method.name || propKey || '';
                            _a.label = 1;
                        case 1:
                            _a.trys.push([1, 3, , 4]);
                            logger === null || logger === void 0 ? void 0 : logger.log.apply(logger, __spreadArray([MODULE_NAME, methodName], __read(args), false));
                            return [4 /*yield*/, method.apply(this, args)];
                        case 2:
                            res = _a.sent();
                            logger === null || logger === void 0 ? void 0 : logger.log(MODULE_NAME, "".concat(methodName, " success: "), res);
                            return [2 /*return*/, res];
                        case 3:
                            err_1 = _a.sent();
                            logger === null || logger === void 0 ? void 0 : logger.error(MODULE_NAME, "".concat(methodName, " failed: "), err_1);
                            throw err_1;
                        case 4: return [2 /*return*/];
                    }
                });
            });
        };
    };
}

function sensitiveInfoFilter(content) {
    var regexs = [
        'scene/apps/[a-z0-9]{32}/',
        '"rtcKey":"[a-z0-9]{32}"',
        '"imKey":"[a-z0-9]{32}"',
        '"appkey":"[a-z0-9]{32}"',
        '"appkey": "[a-z0-9]{32}"',
        'appkey:"[a-z0-9]{32}"',
        'appkey: "[a-z0-9]{32}"',
        '"appkey":[a-z0-9]{32}',
        '"appkey": [a-z0-9]{32}',
        'appkey:[a-z0-9]{32}',
        'appkey: [a-z0-9]{32}',
    ];
    var templates = [
        'scene/apps/***/',
        '"rtcKey":"***"',
        '"imKey":"***"',
        '"appkey":"***"',
        '"appkey": "***"',
        'appkey:"***"',
        'appkey: "***"',
        '"appkey":***',
        '"appkey": ***',
        'appkey:***',
        'appkey: ***',
    ];
    regexs.forEach(function (regex, index) {
        var reg = new RegExp(regex, 'gi');
        content = content.replace(reg, templates[index]);
    });
    return content;
}
var logDebug = function (_a) {
    var _b = _a === void 0 ? {
        appName: '',
        version: '',
        storeWindow: false,
    } : _a, level = _b.level, _c = _b.appName, appName = _c === void 0 ? '' : _c; _b.version; var _e = _b.storeWindow, storeWindow = _e === void 0 ? false : _e;
    var genTime = function () {
        var now = new Date();
        var year = now.getFullYear();
        var month = now.getMonth() + 1;
        var day = now.getDate();
        var hour = now.getHours() < 10 ? "0".concat(now.getHours()) : now.getHours();
        var min = now.getMinutes() < 10 ? "0".concat(now.getMinutes()) : now.getMinutes();
        var s = now.getSeconds() < 10 ? "0".concat(now.getSeconds()) : now.getSeconds();
        var nowString = "".concat(year, "-").concat(month, "-").concat(day, " ").concat(hour, ":").concat(min, ":").concat(s);
        return nowString;
    };
    var genUserAgent = function () {
        try {
            var ua = navigator.userAgent.toLocaleLowerCase();
            var re = /(msie|firefox|chrome|opera|version).*?([\d.]+)/;
            var m = ua.match(re) || [];
            var browser = m[1].replace(/version/, 'safari');
            var ver = m[2];
            return {
                browser: browser,
                ver: ver,
            };
        }
        catch (error) {
            return null;
        }
    };
    var proxyLog = function () {
        var _log = new Proxy(log, {
            get: function (target, prop) {
                var _a, _b;
                if (!(prop in target)) {
                    return;
                }
                var func = target[prop];
                if (!['log', 'info', 'warn', 'error', 'trace', 'debug'].includes(prop)) {
                    return func;
                }
                var prefix = genTime();
                if (genUserAgent()) {
                    prefix += "[".concat((_a = genUserAgent()) === null || _a === void 0 ? void 0 : _a.browser, " ").concat((_b = genUserAgent()) === null || _b === void 0 ? void 0 : _b.ver, "]");
                }
                prefix +=
                    "[".concat({
                        log: 'L',
                        info: 'I',
                        warn: 'W',
                        error: 'E',
                        trace: 'E',
                        debug: 'D',
                    }[prop], "]") +
                        "[".concat(appName, "]") +
                        ':';
                // eslint-disable-next-line @typescript-eslint/no-this-alias
                var that = this;
                return function () {
                    var args = [];
                    for (var _i = 0; _i < arguments.length; _i++) {
                        args[_i] = arguments[_i];
                    }
                    for (var i = 0; i < args.length; i++) {
                        if (typeof args[i] === 'object') {
                            try {
                                args[i] = JSON.stringify(args[i]);
                            }
                            catch (_a) {
                                console.warn('[日志打印对象无法序列化]', args[i]);
                                args[i] = args[i];
                            }
                        }
                        if (typeof args[i] === 'string') {
                            args[i] = sensitiveInfoFilter(args[i]);
                        }
                    }
                    return func.apply(that, __spreadArray([prefix], __read(args), false));
                };
            },
        });
        return _log;
    };
    var logger = proxyLog();
    if (level) {
        logger.setLevel(level);
    }
    if (storeWindow) {
        // @ts-ignore
        window.__LOGGER__ = logger;
    }
    return logger;
};
var logDebug$1 = logDebug;

/**
 * 异步频率控制
 * 一段时间内只请求一次，多余的用这一次执行的结果做为结果
 * @param fn
 * @param delay
 */
var frequencyControl = function (fn, delay) {
    var queue = [];
    var last = 0;
    var timer;
    return function () {
        var _this = this;
        var args = [];
        for (var _i = 0; _i < arguments.length; _i++) {
            args[_i] = arguments[_i];
        }
        return new Promise(function (resolve, reject) {
            queue.push({ resolve: resolve, reject: reject });
            var cur = Date.now();
            var consumer = function (success, res) {
                while (queue.length) {
                    var _a = queue.shift(), resolve_1 = _a.resolve, reject_1 = _a.reject;
                    success ? resolve_1(res) : reject_1(res);
                }
            };
            var excute = function () {
                last = cur;
                if (!queue.length)
                    return;
                // @ts-ignore
                fn.apply(_this, args).then(function (res) {
                    consumer(true, res);
                }, function (err) {
                    consumer(false, err);
                });
            };
            if (cur - last > delay) {
                excute();
            }
            else {
                clearTimeout(timer);
                timer = setTimeout(function () {
                    excute();
                }, delay);
            }
        });
    };
};
function getFileType(filename) {
    var fileMap = {
        img: /(png|gif|jpg)/i,
        pdf: /pdf$/i,
        word: /(doc|docx)$/i,
        excel: /(xls|xlsx)$/i,
        ppt: /(ppt|pptx)$/i,
        zip: /(zip|rar|7z)$/i,
        audio: /(mp3|wav|wmv)$/i,
        video: /(mp4|mkv|rmvb|wmv|avi|flv|mov)$/i,
    };
    return Object.keys(fileMap).find(function (type) { return fileMap[type].test(filename); }) || '';
}
/**
 * 解析输入的文件大小
 * @param size 文件大小，单位b
 * @param level 递归等级，对应fileSizeMap
 */
var parseFileSize = function (size, level) {
    if (level === void 0) { level = 0; }
    var fileSizeMap = {
        0: 'B',
        1: 'KB',
        2: 'MB',
        3: 'GB',
        4: 'TB',
    };
    var handler = function (size, level) {
        if (level >= Object.keys(fileSizeMap).length) {
            return 'the file is too big';
        }
        if (size < 1024) {
            return "".concat(size).concat(fileSizeMap[level]);
        }
        return handler(Math.round(size / 1024), level + 1);
    };
    return handler(size, level);
};
var addUrlSearch = function (url, search) {
    var urlObj = new URL(url);
    urlObj.search += (urlObj.search.startsWith('?') ? '&' : '?') + search;
    return urlObj.href;
};
function debounce(fn, wait) {
    var timer = null;
    return function () {
        var _this = this;
        var args = [];
        for (var _i = 0; _i < arguments.length; _i++) {
            args[_i] = arguments[_i];
        }
        if (timer) {
            clearTimeout(timer);
            timer = null;
        }
        timer = setTimeout(function () {
            // @ts-ignore
            fn.apply(_this, args);
        }, wait);
    };
}

exports.EventTracking = EventTracking$1;
exports.Storage = index;
exports.VisibilityObserver = VisibilityObserver$1;
exports.addUrlSearch = addUrlSearch;
exports.createLoggerDecorator = createLoggerDecorator;
exports.debounce = debounce;
exports.frequencyControl = frequencyControl;
exports.getFileType = getFileType;
exports.logDebug = logDebug$1;
exports.parseFileSize = parseFileSize;
exports.request = request;

}, function(modId) {var map = {}; return __REQUIRE__(map[modId], modId); })
return __REQUIRE__(1689135971672);
})()
//miniprogram-npm-outsideDeps=["axios","eventemitter3"]
//# sourceMappingURL=index.js.map