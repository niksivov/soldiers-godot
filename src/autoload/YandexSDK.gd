extends Node

var initialized: bool = false
var player_lang: String = "ru"
var _pending_save_data: Dictionary = {}
var _pending_load_callback: Callable
var _reward_callback: Callable

signal sdk_ready()
signal rewarded(reward_type: String)
signal interstitial_closed(was_shown: bool)
signal pause_game()
signal resume_game()


func _ready():
    process_mode = Node.PROCESS_MODE_ALWAYS


func init_sdk():
    if not OS.has_feature("web"):
        initialized = true
        sdk_ready.emit()
        return

    var js = """
        YaGames.init().then(function(ysdk) {
            window.ysdk = ysdk;
            window._ysdk_ready = true;

            var lang = ysdk.environment.i18n.lang;
            window._player_lang = lang;

            ysdk.features.LoadingAPI.ready();

            ysdk.on('game_api_pause', function() {
                window._game_paused = true;
            });

            ysdk.on('game_api_resume', function() {
                window._game_paused = false;
            });
        }).catch(function(error) {
            console.log('Yandex SDK init error:', error);
            window._ysdk_ready = false;
        });
    """
    JavaScriptBridge.eval(js)

    await get_tree().create_timer(1.0).timeout

    if OS.has_feature("web"):
        var ready = JavaScriptBridge.eval("typeof window._ysdk_ready !== 'undefined'")
        if ready:
            player_lang = JavaScriptBridge.eval("window._player_lang || 'ru'")
            initialized = true
            sdk_ready.emit()


func show_interstitial():
    if not OS.has_feature("web"):
        interstitial_closed.emit(false)
        return

    var js = """
        window.ysdk.adv.showFullscreenAdv({
            callbacks: {
                onClose: function(wasShown) {
                    window._adv_result = wasShown;
                }
            }
        });
    """
    JavaScriptBridge.eval(js)
    await get_tree().create_timer(0.5).timeout
    var result = JavaScriptBridge.eval("window._adv_result || false")
    interstitial_closed.emit(result)


func show_rewarded_video(reward_type: String = "crystals"):
    if not OS.has_feature("web"):
        return

    var js = """
        window._reward_result = false;
        window.ysdk.adv.showRewardedVideo({
            callbacks: {
                onRewarded: function() {
                    window._reward_result = true;
                },
                onClose: function() {
                    if (window._reward_callback) {
                        window._reward_callback(window._reward_result);
                    }
                }
            }
        });
    """
    JavaScriptBridge.eval(js)
    await get_tree().create_timer(1.0).timeout
    var rewarded = JavaScriptBridge.eval("window._reward_result || false")
    if rewarded:
        rewarded.emit(reward_type)


func save_cloud(data: Dictionary) -> bool:
    if not OS.has_feature("web"):
        return false

    var json_str = JSON.stringify(data)
    var js = """
        (async function() {
            try {
                await window.ysdk.getPlayer().setData({ 'save_data': %s });
                window._save_ok = true;
            } catch(e) {
                window._save_ok = false;
            }
        })();
    """ % json_str
    JavaScriptBridge.eval(js)
    await get_tree().create_timer(0.5).timeout

    if OS.has_feature("web"):
        return JavaScriptBridge.eval("window._save_ok || false")
    return false


func load_cloud() -> Dictionary:
    if not OS.has_feature("web"):
        return {}

    var js = """
        (async function() {
            try {
                var data = await window.ysdk.getPlayer().getData(['save_data']);
                window._load_data = JSON.stringify(data.save_data || {});
            } catch(e) {
                window._load_data = '{}';
            }
        })();
    """
    JavaScriptBridge.eval(js)
    await get_tree().create_timer(0.5).timeout

    if OS.has_feature("web"):
        var json_str = JavaScriptBridge.eval("window._load_data || '{}'")
        var json = JSON.new()
        if json.parse(json_str) == OK:
            return json.data
    return {}


func check_pause_resume():
    if not OS.has_feature("web"):
        return
    var paused = JavaScriptBridge.eval("window._game_paused || false")
    if paused:
        pause_game.emit()
    else:
        resume_game.emit()
