package com.hexmonarch.hexmonarch

import android.app.AlarmManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.SystemClock
import org.json.JSONArray
import org.json.JSONObject

/**
 * Notifications with no server. The game simulation is deterministic, so when the app goes to
 * the background the Dart side already knows what will happen in the coming days and hands over
 * a list of alerts, each with a delay. They are queued as inexact alarms on the monotonic clock
 * (editing the date does not move them) and mirrored in preferences so they can be queued again
 * after a reboot.
 */
object AlertScheduler {
    const val ACTION = "com.hexmonarch.hexmonarch.ALERT"
    private const val CHANNEL_URGENT = "attacks"
    private const val CHANNEL_CALM = "opportunities"
    private const val PREFS = "hexmonarch_alerts"
    private const val KEY = "queue"
    private const val BASE_ID = 7100

    private data class Alert(val id: Int, val atWall: Long, val title: String, val body: String, val urgent: Boolean)

    private fun ensureChannels(context: Context) {
        val nm = context.getSystemService(NotificationManager::class.java) ?: return
        nm.createNotificationChannel(
            NotificationChannel(CHANNEL_URGENT, "Attacks on your turf", NotificationManager.IMPORTANCE_HIGH).apply {
                description = "Raids, turfs about to fall, turfs lost, offensives."
                enableVibration(true)
            },
        )
        nm.createNotificationChannel(
            NotificationChannel(CHANNEL_CALM, "Opportunities", NotificationManager.IMPORTANCE_LOW).apply {
                description = "Convoys, dead drops, lockdowns, full energy."
            },
        )
    }

    /** Replaces everything queued. Each entry: inMs (delay from now), title, body, urgent. */
    fun schedule(context: Context, alerts: List<Map<String, Any?>>) {
        cancelAll(context, dismiss = false)
        ensureChannels(context)
        val wall = System.currentTimeMillis()
        val queue = alerts.mapIndexedNotNull { i, a ->
            val delay = (a["inMs"] as? Number)?.toLong() ?: return@mapIndexedNotNull null
            val title = a["title"] as? String ?: return@mapIndexedNotNull null
            Alert(BASE_ID + i, wall + delay, title, a["body"] as? String ?: "", a["urgent"] == true)
        }
        save(context, queue)
        queue.forEach { arm(context, it, wall) }
    }

    /** Drops every queued alert; [dismiss] also clears the ones already on screen. */
    fun cancelAll(context: Context, dismiss: Boolean) {
        val am = context.getSystemService(AlarmManager::class.java)
        val nm = context.getSystemService(NotificationManager::class.java)
        for (a in load(context)) {
            am?.cancel(pending(context, a))
            if (dismiss) nm?.cancel(a.id)
        }
        save(context, emptyList())
    }

    /** After a reboot: alarms are gone, the queue is not. */
    fun rearm(context: Context) {
        val wall = System.currentTimeMillis()
        val queue = load(context)
        queue.filter { it.atWall > wall }.forEach { arm(context, it, wall) }
        // What came due while the phone was off: show the latest, not a pile.
        queue.filter { it.atWall <= wall && it.urgent }.maxByOrNull { it.atWall }?.let {
            post(context, it.id, it.title, it.body, true)
        }
    }

    fun post(context: Context, id: Int, title: String, body: String, urgent: Boolean) {
        ensureChannels(context)
        val nm = context.getSystemService(NotificationManager::class.java) ?: return
        val open = context.packageManager.getLaunchIntentForPackage(context.packageName)?.let {
            PendingIntent.getActivity(context, 0, it, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        }
        val notification = Notification.Builder(context, if (urgent) CHANNEL_URGENT else CHANNEL_CALM)
            .setSmallIcon(R.drawable.ic_stat_hex)
            .setContentTitle(title)
            .setContentText(body.lineSequence().firstOrNull() ?: "")
            .setStyle(Notification.BigTextStyle().bigText(body))
            .setColor(if (urgent) 0xFFFF3B5C.toInt() else 0xFF00C980.toInt())
            .setCategory(Notification.CATEGORY_STATUS)
            .setAutoCancel(true)
            .setShowWhen(true)
            .setContentIntent(open)
            .build()
        try {
            nm.notify(id, notification)
        } catch (_: SecurityException) {
            // Notifications were switched off after this was queued.
        }
    }

    private fun arm(context: Context, a: Alert, wallNow: Long) {
        val am = context.getSystemService(AlarmManager::class.java) ?: return
        val at = SystemClock.elapsedRealtime() + (a.atWall - wallNow).coerceAtLeast(1000L)
        am.setAndAllowWhileIdle(AlarmManager.ELAPSED_REALTIME_WAKEUP, at, pending(context, a))
    }

    private fun pending(context: Context, a: Alert): PendingIntent {
        val intent = Intent(context, AlertReceiver::class.java)
            .setAction(ACTION)
            .putExtra("id", a.id)
            .putExtra("title", a.title)
            .putExtra("body", a.body)
            .putExtra("urgent", a.urgent)
        return PendingIntent.getBroadcast(context, a.id, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
    }

    private fun save(context: Context, queue: List<Alert>) {
        val json = JSONArray()
        for (a in queue) {
            json.put(
                JSONObject()
                    .put("id", a.id)
                    .put("at", a.atWall)
                    .put("title", a.title)
                    .put("body", a.body)
                    .put("urgent", a.urgent),
            )
        }
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit().putString(KEY, json.toString()).apply()
    }

    private fun load(context: Context): List<Alert> {
        val raw = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getString(KEY, null) ?: return emptyList()
        return try {
            val json = JSONArray(raw)
            List(json.length()) { i ->
                val o = json.getJSONObject(i)
                Alert(o.getInt("id"), o.getLong("at"), o.getString("title"), o.optString("body"), o.optBoolean("urgent"))
            }
        } catch (_: Exception) {
            emptyList()
        }
    }
}

/** Fires when a queued alert comes due: shows it. */
class AlertReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != AlertScheduler.ACTION) return
        val title = intent.getStringExtra("title") ?: return
        AlertScheduler.post(
            context,
            intent.getIntExtra("id", 0),
            title,
            intent.getStringExtra("body") ?: "",
            intent.getBooleanExtra("urgent", false),
        )
    }
}

/** Alarms do not survive a reboot. */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) AlertScheduler.rearm(context)
    }
}
