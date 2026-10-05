package wtf.openstrap.openstrap_edge

import android.content.Context
import android.content.res.Configuration
import java.util.Locale

/** Uses the same saved override as Flutter; no override follows Android. */
internal fun uiString(context: Context, resource: Int): String {
    val code = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        .getString("flutter.locale_override", null)
    if (code.isNullOrEmpty()) return context.getString(resource)
    val configuration = Configuration(context.resources.configuration)
    configuration.setLocale(Locale.forLanguageTag(code))
    return context.createConfigurationContext(configuration).getString(resource)
}
