package com.nossoamor.contador

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import java.io.File

/// Widget "dias juntos". Se houver foto (Premium/vídeo), mostra a foto do casal
/// ao fundo com um véu escuro pro texto; senão o gradiente do tema. A foto é
/// decodificada e reduzida aqui (nada de renderFlutterWidget). Tocar abre o app.
class CoupleWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        val style = widgetData.getString("style", "full") ?: "full"
        val layout = when (style) {
            "minimal" -> R.layout.couple_widget_minimal
            "heart" -> R.layout.couple_widget_heart
            else -> R.layout.couple_widget
        }
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, layout)

            val intent = Intent(context, MainActivity::class.java)
            val flags = PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            views.setOnClickPendingIntent(
                R.id.widget_frame,
                PendingIntent.getActivity(context, 0, intent, flags)
            )

            val days = widgetData.getString("days", "0") ?: "0"
            val couple = widgetData.getString("couple", "Nós dois") ?: "Nós dois"
            val theme = widgetData.getString("theme", "sunset") ?: "sunset"
            views.setTextViewText(R.id.widget_days, days)
            views.setTextViewText(R.id.widget_label, couple)

            val photoPath = widgetData.getString("photoPath", "") ?: ""
            val bmp = decodePhoto(photoPath)
            if (bmp != null) {
                // Foto ao fundo + véu escuro pra ler o texto branco.
                views.setImageViewBitmap(R.id.widget_image, bmp)
                views.setViewVisibility(R.id.widget_image, View.VISIBLE)
                views.setInt(R.id.widget_root, "setBackgroundResource", R.drawable.widget_scrim)
            } else {
                views.setViewVisibility(R.id.widget_image, View.GONE)
                val bg = when (theme) {
                    "rosa" -> R.drawable.widget_bg_rosa
                    "paixao" -> R.drawable.widget_bg_paixao
                    "lilas" -> R.drawable.widget_bg_lilas
                    "oceano" -> R.drawable.widget_bg_oceano
                    "dourado" -> R.drawable.widget_bg_dourado
                    "noite" -> R.drawable.widget_bg_noite
                    else -> R.drawable.widget_bg
                }
                views.setInt(R.id.widget_root, "setBackgroundResource", bg)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    /// Decodifica a foto já reduzida (evita estourar o limite do RemoteViews).
    private fun decodePhoto(path: String): android.graphics.Bitmap? {
        if (path.isEmpty() || !File(path).exists()) return null
        return try {
            val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
            BitmapFactory.decodeFile(path, bounds)
            var sample = 1
            val target = 400
            while (bounds.outWidth / sample > target || bounds.outHeight / sample > target) {
                sample *= 2
            }
            val opts = BitmapFactory.Options().apply { inSampleSize = sample }
            BitmapFactory.decodeFile(path, opts)
        } catch (e: Exception) {
            null
        }
    }
}
