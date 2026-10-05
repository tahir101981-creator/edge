package wtf.openstrap.openstrap_edge

import android.content.Context

/** Display adapter only. Snapshot keys, values, freshness and ring math are unchanged. */
internal fun widgetText(context: Context, text: String): String {
    val resource = when (text) {
        "no sleep was scored for this day — resting HR is only ever measured over a sleep window, never over waking hours." -> R.string.widget_second_reason_0
        "Baevsky Stress Index → 0–100; resting autonomic tension (PRV)." -> R.string.widget_second_reason_1
        "no readiness inputs present — \"—\" (never imputed)." -> R.string.widget_second_reason_2
        "Your age is not on file, and this is worked out from it." -> R.string.widget_presentation_0
        "Your weight is not on file, and this is worked out from it." -> R.string.widget_presentation_1
        "Your height is not on file, and this is worked out from it." -> R.string.widget_presentation_2
        "Your sex is not on file, and the formula behind this needs it." -> R.string.widget_presentation_3
        "No waking heart rate was recorded for this day." -> R.string.widget_presentation_4
        "Too few heart-rate samples were recorded to work this out." -> R.string.widget_presentation_5
        "There is no resting heart rate from a scored night to measure against." -> R.string.widget_presentation_6
        "There is no scored night to read this from." -> R.string.widget_presentation_7
        "Too few clean beat-to-beat intervals to work this out." -> R.string.widget_presentation_8
        "Too few half-hour stretches of clean breathing through the night to compare against each other." -> R.string.widget_presentation_9
        "No motion was recorded alongside the heart rate." -> R.string.widget_presentation_10
        "This day came from an imported export, which carries the night only — nothing was recorded for the waking day, and there is no raw behind it to work one out from." -> R.string.widget_presentation_11
        "Today has not produced any activity to read yet — nothing has reached the app for it." -> R.string.widget_presentation_12
        "That night has no total sleep time behind it." -> R.string.widget_presentation_13
        "That night has no wake time behind it." -> R.string.widget_presentation_14
        "That night has no sleep efficiency behind it." -> R.string.widget_presentation_15
        "The band has not yet held a high enough heart rate through a hard effort to measure a ceiling from." -> R.string.widget_presentation_16
        "The highest heart rate held so far sits well below what your age predicts, so it reads as an effort that was never maximal rather than as your ceiling — the zones stay on the age estimate until the band sees a harder one." -> R.string.widget_presentation_17
        "Not enough nights of resting heart rate behind the reserve yet." -> R.string.widget_presentation_18
        "You have set your zones manually, so there is no measured reserve anchor to plot a distribution against." -> R.string.widget_presentation_19
        "Too few recorded sessions to describe a pattern rather than noise." -> R.string.widget_presentation_20
        "These recordings are not stamped with which strap made them, and this number has to be calibrated per strap, so it is withheld rather than guessed." -> R.string.widget_presentation_21
        "Last night is still being worked out." -> R.string.widget_presentation_22
        "Nothing from last night has reached the app yet." -> R.string.widget_presentation_23
        "No night long enough to score was recorded." -> R.string.widget_presentation_24
        "Nothing recorded says why this is missing." -> R.string.widget_presentation_25
        "Not enough history yet to know what normal looks like for you." -> R.string.widget_presentation_26
        "No strain" -> R.string.widget_presentation_27
        "No sleep" -> R.string.widget_presentation_28
        "No readiness" -> R.string.widget_presentation_29
        "No target yet" -> R.string.widget_presentation_30
        "Calibrating" -> R.string.widget_presentation_31
        "days" -> R.string.widget_presentation_32
        "nights" -> R.string.widget_presentation_33
        "doses" -> R.string.widget_presentation_34
        "Reps" -> R.string.widget_presentation_35
        "Rounds" -> R.string.widget_presentation_36
        "Poses" -> R.string.widget_presentation_37
        "Hard minutes" -> R.string.widget_presentation_38
        "Avg HR" -> R.string.widget_presentation_39
        "Max HR" -> R.string.widget_presentation_40
        "HR recovery" -> R.string.widget_presentation_41
        "VO2max (est.)" -> R.string.widget_presentation_42
        "Your rating" -> R.string.widget_presentation_43
        "View data" -> R.string.widget_presentation_44
        "score" -> R.string.widget_presentation_45
        "RECOVERY" -> R.string.widget_presentation_46
        "STRAIN" -> R.string.widget_presentation_47
        "SLEEP" -> R.string.widget_presentation_48
        "Not measured" -> R.string.widget_presentation_49
        "Not connected yet" -> R.string.widget_presentation_50
        "Strap" -> R.string.widget_presentation_51
        "bpm" -> R.string.widget_presentation_52
        "ms" -> R.string.widget_presentation_53
        "base" -> R.string.widget_presentation_54
        "efficient" -> R.string.widget_presentation_55
        "last known" -> R.string.widget_presentation_56
        "Not scored" -> R.string.widget_presentation_57
        "High" -> R.string.widget_presentation_58
        "Good" -> R.string.widget_presentation_59
        "Moderate" -> R.string.widget_presentation_60
        "Low" -> R.string.widget_presentation_61
        else -> null
    }
    if (resource != null) return uiString(context, resource)
    // Duration and unit formatting uses the same saved language override.
    if (widgetText(context, "bpm") == "bpm") return text
    val gap = Regex("^(.*?)(?: )?Your band was off your wrist (.+?) – (.+?)\\.$").matchEntire(text)
    if (gap != null) {
        val prefix = gap.groupValues[1].trimEnd()
        return (if (prefix.isEmpty()) "" else widgetText(context, prefix) + " ") +
            uiString(context, R.string.widget_off_wrist_span, gap.groupValues[2], gap.groupValues[3])
    }
    val count = Regex("^(.*?) There were (\\d+), and it needs (\\d+)\\.$").matchEntire(text)
    if (count != null) return uiString(context, R.string.widget_reason_count,
        widgetText(context, count.groupValues[1]), count.groupValues[2], count.groupValues[3])
    val need = Regex("^Need (\\d+) more nights?$").matchEntire(text)
    if (need != null) return uiQuantity(context, R.plurals.widget_need_nights,
        need.groupValues[1].toInt())
    val days = Regex("^Wear (\\d+) more days? to unlock$").matchEntire(text)
    if (days != null) return uiQuantity(context, R.plurals.widget_need_days,
        days.groupValues[1].toInt())
    return text
        .replace(Regex("^(\\d+)h (\\d+)m$"), "\$1 ч \$2 мин")
        .replace(Regex("^(\\d+)m$"), "\$1 мин")
        .replace(Regex("^(\\d+) bpm$"), "\$1 уд/мин")
        .replace(Regex("^(\\d+) ms$"), "\$1 мс")
        .replace(Regex("^base (\\d+) ms$"), "база $1 мс")
        .replace(Regex("^(\\d+)% efficient$"), "\$1% эффективность")
        .replace(Regex("^(.*?) · last known$"), "\$1 · последние данные")
        .replace(Regex("^(.*?) of (.*?) nights$"), "\$1 из \$2 ночей")
        .replace(Regex("^(.*?) of (.*?) days$"), "\$1 из \$2 дней")
        .replace(Regex("^of (.*)$"), "из $1")
}
