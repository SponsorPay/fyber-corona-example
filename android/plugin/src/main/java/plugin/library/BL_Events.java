package plugin.library;

import java.util.Map;

public class BL_Events {

    private static final String LOG_TAG = "FYBER_LIB";

    public static void sendRuntimeEvent(final String eventName, final Map<String, String> parameters) {

        com.ansca.corona.CoronaActivity activity = com.ansca.corona.CoronaEnvironment.getCoronaActivity();

        if (activity != null) {
            activity.getRuntimeTaskDispatcher().send(new com.ansca.corona.CoronaRuntimeTask() {
                @Override
                public void executeUsing(com.ansca.corona.CoronaRuntime runtime) {

                    //Log.d(LOG_TAG, "sendRuntimeEvent " + eventName);

                    // *** We are now running on the Corona runtime thread. ***
                    // Fetch the Corona runtime's Lua state.
                    com.naef.jnlua.LuaState luaState = runtime.getLuaState();

                    luaState.getGlobal("Runtime");
                    luaState.getField(-1, "dispatchEvent");
                    luaState.pushValue(-2);
                    luaState.newTable();
                    int idx = luaState.getTop();

                    luaState.pushString(eventName);
                    luaState.setField(idx, "name");
                    if (parameters != null) {
                        for (Map.Entry<String, String> entry : parameters.entrySet()) {
                            luaState.pushString(entry.getValue());
                            luaState.setField(idx, entry.getKey());
                        }
                    }
                    luaState.call(2, 0);
                    return;
                }
            });
        }
    }

}