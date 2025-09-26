module.exports = (function() {
var __MODS__ = {};
var __DEFINE__ = function(modId, func, req) { var m = { exports: {}, _tempexports: {} }; __MODS__[modId] = { status: 0, func: func, req: req, m: m }; };
var __REQUIRE__ = function(modId, source) { if(!__MODS__[modId]) return require(source); if(!__MODS__[modId].status) { var m = __MODS__[modId].m; m._exports = m._tempexports; var desp = Object.getOwnPropertyDescriptor(m, "exports"); if (desp && desp.configurable) Object.defineProperty(m, "exports", { set: function (val) { if(typeof val === "object" && val !== m._exports) { m._exports.__proto__ = val.__proto__; Object.keys(val).forEach(function (k) { m._exports[k] = val[k]; }); } m._tempexports = val }, get: function () { return m._tempexports; } }); __MODS__[modId].status = 1; __MODS__[modId].func(__MODS__[modId].req, m, m.exports); } return __MODS__[modId].m.exports; };
var __REQUIRE_WILDCARD__ = function(obj) { if(obj && obj.__esModule) { return obj; } else { var newObj = {}; if(obj != null) { for(var k in obj) { if (Object.prototype.hasOwnProperty.call(obj, k)) newObj[k] = obj[k]; } } newObj.default = obj; return newObj; } };
var __REQUIRE_DEFAULT__ = function(obj) { return obj && obj.__esModule ? obj.default : obj; };
__DEFINE__(1670910583184, function(require, module, exports) {


Object.defineProperty(exports, '__esModule', { value: true });

var axios = require('axios');

function _interopDefaultLegacy (e) { return e && typeof e === 'object' && 'default' in e ? e : { 'default': e }; }

var axios__default = /*#__PURE__*/_interopDefaultLegacy(axios);

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

var request = function (_a) {
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
var webRequestHelper = request;

var url = "https://statistic.live.126.net/statics/report/xkit/action";
var EventTracking = /** @class */ (function () {
    function EventTracking(_a) {
        var appKey = _a.appKey, version = _a.version, component = _a.component, nertcVersion = _a.nertcVersion, imVersion = _a.imVersion, _b = _a.platform, platform = _b === void 0 ? 'web' : _b;
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
                        return [4 /*yield*/, webRequestHelper({
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
        img: /(png|gif|jpg)/,
        pdf: /pdf$/,
        word: /(doc|docx)$/,
        excel: /(xls|xlsx)$/,
        ppt: /(ppt|pptx)$/,
        zip: /(zip|rar|7z)$/,
        audio: /(mp3|wav|wmv)$/,
        video: /(mp4|mkv|rmvb|wmv|avi|flv|mov)$/,
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
exports.Storage = webStorage;
exports.addUrlSearch = addUrlSearch;
exports.debounce = debounce;
exports.frequencyControl = frequencyControl;
exports.getFileType = getFileType;
exports.parseFileSize = parseFileSize;
exports.request = webRequestHelper;

}, function(modId) {var map = {}; return __REQUIRE__(map[modId], modId); })
return __REQUIRE__(1670910583184);
})()
//miniprogram-npm-outsideDeps=["axios"]
//# sourceMappingURL=index.js.map