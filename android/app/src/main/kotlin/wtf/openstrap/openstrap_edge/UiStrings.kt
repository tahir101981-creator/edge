package wtf.openstrap.openstrap_edge

import android.content.Context
import android.content.res.Configuration
import java.util.Locale

/** Uses the same saved override as Flutter; no override follows Android. */
private fun uiContext(context: Context): Context {
    val code = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        .getString("flutter.locale_override", null)
    if (code.isNullOrEmpty()) return context
    val configuration = Configuration(context.resources.configuration)
    configuration.setLocale(Locale.forLanguageTag(code))
    return context.createConfigurationContext(configuration)
}

internal fun uiString(context: Context, resource: Int, vararg args: Any): String =
    uiContext(context).getString(resource, *args)

internal fun uiQuantity(context: Context, resource: Int, count: Int): String =
    uiContext(context).resources.getQuantityString(resource, count, count)
