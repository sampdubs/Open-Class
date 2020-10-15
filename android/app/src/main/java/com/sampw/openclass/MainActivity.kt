package com.sampw.openclass

import android.content.DialogInterface
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.os.Bundle
import android.view.View
import android.widget.TextView
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import java.lang.Exception
import java.util.*
import kotlin.math.abs


class MainActivity : AppCompatActivity() {

    private fun makeDate(hour: Int, minute: Int): Date {
        var date =  Calendar.getInstance()
        date.set(Calendar.HOUR_OF_DAY, hour)
        date.set(Calendar.MINUTE, minute)
        date.set(Calendar.SECOND, 0)
        return date.time
    }

    private fun dateToTimeString(date: Date): String {
        val cal = Calendar.getInstance()
        cal.time = date
        return cal.get(Calendar.HOUR_OF_DAY).toString() + ":" + cal.get(Calendar.MINUTE)
    }

//    private fun stringArrToDates(times: String): MutableList<Date> {
//        var dates = MutableList<Date>(0)
//        for (t in times) {
//        }
//    }

    private val classTimes: List<Date> = listOf(
        makeDate(8, 30),
        makeDate(8, 50),
        makeDate(10, 15),
        makeDate(12, 10),
        makeDate(13, 35),
    )


    private lateinit var preferences: SharedPreferences

    private lateinit var classNames: MutableList<String>

    private lateinit var classLinks: MutableList<String>

//    private lateinit var classTimes: MutableList<Date>

    private var linkToOpen = "https://large-type.com/#You%20have%20not%20set%20up%20this%20zoom%20link%20yet"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        preferences = applicationContext.getSharedPreferences(
            "com.sampw.openclass.preferences",
            MODE_PRIVATE
        )
        classNames =
            preferences.getString(
                "classNames", JSON

                "Class name not set;;,".repeat(5).substringBeforeLast(
                    ";;,"
                )
            )!!.split(";;,").toMutableList()
        classLinks = preferences.getString(
            "classLinks",
            "https://large-type.com/#You%20have%20not%20set%20up%20this%20zoom%20link%20yet;;,".repeat(
                5
            ).substringBeforeLast(";;,")
        )!!.split(";;,").toMutableList()

        // get real start time
        val currentTime = Calendar.getInstance().time.time
        var winningDist = Long.MAX_VALUE
        var winningIndex = 0
        for (i in classTimes.indices) {
            val dist = abs(classTimes[i].time - currentTime)
            if (dist < winningDist) {
                winningDist = dist
                winningIndex = i
            }
        }

        findViewById<TextView>(R.id.timeText).apply {
            text = dateToTimeString(classTimes[winningIndex])
        }

        findViewById<TextView>(R.id.className).apply {
            text = classNames[winningIndex]
        }
        linkToOpen = classLinks[winningIndex]
    }

    fun openLink(view: View) {
        try {
            val browserIntent = Intent(Intent.ACTION_VIEW, Uri.parse(linkToOpen))
            startActivity(browserIntent)
        } catch (e: Exception) {
            try {
                val browserIntent = Intent(Intent.ACTION_VIEW, Uri.parse("https://" + linkToOpen))
                startActivity(browserIntent)
            } catch (f: Exception) {
                val alertBuilder = AlertDialog.Builder(this)
                alertBuilder.setTitle("Invalid URL")
                alertBuilder.setMessage("The link set for this class is not a valid URL")
                alertBuilder.setCancelable(true)
                alertBuilder.setNeutralButton("OK", DialogInterface.OnClickListener { dialog, which -> dialog.cancel() })
                val alertDialog = alertBuilder.create()
                alertDialog.show()
            }
        }
    }

    fun openSettings(view: View) {
        val settingsIntent = Intent(this, SettingsActivity::class.java)
        startActivity(settingsIntent)
    }
}