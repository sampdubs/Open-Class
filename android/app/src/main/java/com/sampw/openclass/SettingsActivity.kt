package com.sampw.openclass

import android.content.Context
import android.content.SharedPreferences
import android.graphics.Rect
import android.os.Bundle
import android.util.Log
import android.view.*
import android.view.inputmethod.InputMethodManager
import android.widget.BaseAdapter
import android.widget.EditText
import android.widget.ListView
import androidx.appcompat.app.AppCompatActivity
import kotlinx.android.synthetic.main.class_settings.view.*
import java.util.*
import kotlin.math.min

class SettingsActivity : AppCompatActivity() {

    lateinit var listAdapter : ListAdapter

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        listAdapter = ListAdapter(applicationContext)
        setContentView(R.layout.activity_settings)
        val listView = findViewById<ListView>(R.id.listView)
        listView.adapter = listAdapter
    }

    override fun onBackPressed() {
        listAdapter.saveAll()
        super.onBackPressed()
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        if (item.itemId == android.R.id.home) {
            listAdapter.saveAll()
        }
        return (super.onOptionsItemSelected(item));
    }

    override fun dispatchTouchEvent(event: MotionEvent): Boolean {
        if (event.action == MotionEvent.ACTION_DOWN) {
            val v = currentFocus
            if (v is EditText) {
                val outRect = Rect()
                v.getGlobalVisibleRect(outRect)
                if (!outRect.contains(event!!.getRawX().toInt(), event!!.getRawY().toInt())) {
                    Log.d("focus", "touchevent")
                    v.clearFocus()
                    val imm = getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
                    imm.hideSoftInputFromWindow(v.windowToken, 0)
                }
            }
        }
        return super.dispatchTouchEvent(event)
    }

    class ListAdapter(context: Context) : BaseAdapter() {

        private val overContext = context

        private val preferences: SharedPreferences =
            overContext.getSharedPreferences("com.sampw.openclass.preferences", MODE_PRIVATE)

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

        private val classTimes: List<Date> = listOf(
            makeDate(8, 30),
            makeDate(8, 50),
            makeDate(10, 15),
            makeDate(12, 10),
            makeDate(13, 35),
        )


        private var classNames =
            preferences.getString("classNames", "Class name not set;;,".repeat(5).substringBeforeLast(";;,"))!!.split(";;,").toMutableList()

        private var classLinks = preferences.getString(
            "classLinks",
            "https://large-type.com/#You%20have%20not%20set%20up%20this%20zoom%20link%20yet;;,".repeat(5).substringBeforeLast(";;,")
        )!!.split(";;,").toMutableList()

        private lateinit var listView: ListView

        fun saveAll() {
            for (index in this.classTimes.indices) {
                val view = listView.getChildAt(index)
                classNames[index] = view.classNameInput.text.toString()
                classLinks[index] = view.classLinkInput.text.toString()
            }
            val editor = preferences.edit()
            editor.clear()
            editor.putString("classLinks", classLinks.joinToString(separator = ";;,")).putString("classNames", classNames.joinToString(separator = ";;,")).apply()
        }

        override fun getCount(): Int {
            return classNames.count()
        }


        override fun getItem(index: Int): Any {
            return classNames[index]
        }

        override fun getItemId(index: Int): Long {
            return index.toLong()
        }

        override fun getView(index: Int, convertView: View?, parent: ViewGroup?): View {

            val inflater = LayoutInflater.from(overContext)
            val classView: View = inflater.inflate(R.layout.class_settings, parent, false)
            listView = parent as ListView
            classView.classNameInput.setText(classNames[index])
            classView.classLinkInput.setText(classLinks[index])
            classView.timeLabel.text = dateToTimeString(classTimes.elementAt(index))

            classView.classNameInput.onFocusChangeListener = View.OnFocusChangeListener(
                fun(view: View, b: Boolean) {
                    if (!b) {
                        val editor = preferences.edit()
                        editor.clear()
                        classNames[index] = classView.classNameInput.text.toString()
                        editor.putString("classNames", classNames.joinToString(separator = ";;,")).apply()
                    }
                })

            classView.classLinkInput.onFocusChangeListener = View.OnFocusChangeListener(
                fun(view: View, b: Boolean) {
                    if (!b) {
                        val editor = preferences.edit()
                        editor.clear()
                        classLinks[index] = classView.classLinkInput.text.toString()
                        editor.putString("classLinks", classLinks.joinToString(separator = ";;,")).apply()
                    }
                })

            return classView
        }

    }
}