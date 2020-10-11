
from fbs_runtime.application_context.PyQt5 import ApplicationContext
from PyQt5.QtWidgets import *
from PyQt5.QtGui import *
from PyQt5.QtCore import *

import sys, webbrowser, shelve, os
from datetime import datetime

class MainWindow(QWidget):
    def __init__(self):
        super().__init__()

        self.TIMES = [(8, 30), (8, 50), (10, 15), (12, 10), (13, 35)]
        self.NEWCLASS = False
        
        path = ""
        if os.name == "nt":
            path = os.getenv('APPDATA')
            path = os.path.join(path, "ZoomToClass")
        else:
            path = os.path.expanduser("~/.ZoomToClass")
        if not os.path.exists(path):
            os.mkdir(path)
        self.path = os.path.join(path, "links")


        db = shelve.open(self.path)
        if "links" not in db:
            db["links"] = {t: ("Class name not set", "https://large-type.com/#You%20have%20not%20set%20up%20this%20zoom%20link%20yet") for t in self.TIMES}
        links = db["links"]
        db.close()

        self.layout = QGridLayout()
        self.setGeometry(100, 100, 600, 400)
        self.setLayout(self.layout)
        self.makeMainUI()

    def makeMainUI(self):
        self.clearLayout(self.layout)
        db = shelve.open(self.path)
        if "links" not in db:
            db["links"] = {t: ("Class name not set", "https://large-type.com/#You%20have%20not%20set%20up%20this%20zoom%20link%20yet") for t in self.TIMES}
        links = db["links"]

        classTime = self.findClosest(links.keys())
        classInfo = links[classTime]

        nameLabel = QLabel(classInfo[0])

        timeLabel = QLabel(f"{classTime[0]}:{classTime[1]}")

        openButton = QPushButton("Open")
        openButton.clicked.connect(lambda: webbrowser.open(classInfo[1]))


        nameLabel.setSizePolicy(QSizePolicy.Fixed, QSizePolicy.Fixed)
        timeLabel.setSizePolicy(QSizePolicy.Fixed, QSizePolicy.Fixed)
        openButton.setSizePolicy(QSizePolicy.Fixed, QSizePolicy.Fixed)


        miniLayout = QVBoxLayout()
        miniLayout.addWidget(nameLabel)
        miniLayout.addWidget(timeLabel)
        miniLayout.addWidget(openButton)
        miniLayout.setSpacing(0)
        miniLayout.setAlignment(nameLabel, Qt.AlignCenter)
        miniLayout.setAlignment(timeLabel, Qt.AlignCenter)
        miniLayout.setAlignment(openButton, Qt.AlignCenter)

        self.layout.addLayout(miniLayout, 1, 0, Qt.AlignCenter)

        db.close()

        settingsButton = QPushButton("Settings")
        settingsButton.setAutoFillBackground(True)
        settingsButton.clicked.connect(self.makeSettingsUI)

        self.layout.addWidget(settingsButton, 0, 0, 1, 1, Qt.AlignLeft | Qt.AlignTop)
        self.layout.setRowStretch(0, 0)
        self.layout.setRowStretch(1, 1)

    def makeFunction(self, func, args):
        def wrapper():
            func(*args)
        return wrapper

    def findClosest(self, times):
        now = datetime.now()
        winningDist = 10 ** 5
        winner = ()
        for time in times:
            ts = now.replace(hour=time[0], minute=time[1]).timestamp()
            dist = abs(ts - now.timestamp())
            if dist < winningDist:
                winningDist = dist
                winner = time
        return winner


    def makeSettingsUI(self, db=None):
        self.clearLayout(self.layout)
        if not db:
            db = shelve.open(self.path, writeback=True)
        links = db["links"]
        self.timeBoxes = []
        self.titleBoxes = []
        self.linkBoxes = []
        i = 0
        mainGrid = QGridLayout()

        submitButton = QPushButton("Save")
        submitButton.clicked.connect(lambda: self.saveLinks(db))
        submitButton.setSizePolicy(QSizePolicy.Fixed, QSizePolicy.Fixed)

        timeTitle = QLabel("Class Time\n(24hr)")
        nameTitle = QLabel("Class Name")
        # nameTitle.setSizePolicy(QSizePolicy.Fixed, QSizePolicy.Fixed)
        linkTitle = QLabel("Link to Class Zoom")
        linkTitle.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding)

        mainGrid.addWidget(submitButton, 0, 0, 1, 1, Qt.AlignLeft | Qt.AlignTop)
        mainGrid.addWidget(timeTitle, 1, 0)
        mainGrid.addWidget(nameTitle, 1, 1)
        mainGrid.addWidget(linkTitle, 1, 2)

        i = 2
        for time in sorted(links.keys()):
            timeLayout = QHBoxLayout()
            hourBox = QLineEdit()
            hourBox.setText(str(time[0]))
            hourBox.setValidator(QIntValidator(0, 23))
            minuteBox = QLineEdit()
            minuteBox.setText(str(time[1]))
            minuteBox.setValidator(QIntValidator(0, 59))
            timeLayout.addWidget(hourBox)
            timeLayout.addWidget(QLabel(":"))
            timeLayout.addWidget(minuteBox)

            nameBox = QLineEdit()
            nameBox.setPlaceholderText(f"Enter period {i - 1} class name here")
            nameBox.setText(links[time][0])
            nameBox.setMinimumSize(QSize(200, 10))
            nameBox.setSizePolicy(QSizePolicy.Fixed, QSizePolicy.Expanding)

            linkBox = QLineEdit()
            linkBox.setPlaceholderText(f"Enter period {i - 1} zoom link here")
            linkBox.setText(links[time][1])
            linkBox.setMinimumSize(QSize(500, 10))
            linkBox.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding)

            deleteButton = QPushButton("X")
            deleteButton.setStyleSheet("QPushButton {color: red; font-weight:600;}")
            deleteButton.clicked.connect(self.makeFunction(self.deleteLink, (time, db)))
            deleteButton.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding)
            
            mainGrid.addLayout(timeLayout, i, 0)
            mainGrid.addWidget(nameBox, i, 1)
            mainGrid.addWidget(linkBox, i, 2)
            mainGrid.addWidget(deleteButton, i, 3)

            self.timeBoxes.append((hourBox, minuteBox))
            self.titleBoxes.append(nameBox)
            self.linkBoxes.append(linkBox)
            i += 1

        if self.NEWCLASS:
            timeLayout = QHBoxLayout()
            hourBox = QLineEdit()
            hourBox.setText("")
            hourBox.setValidator(QIntValidator(0, 23))
            minuteBox = QLineEdit()
            minuteBox.setText("")
            minuteBox.setValidator(QIntValidator(0, 59))
            timeLayout.addWidget(hourBox)
            timeLayout.addWidget(QLabel(":"))
            timeLayout.addWidget(minuteBox)

            nameBox = QLineEdit()
            nameBox.setPlaceholderText(f"Enter period {i - 1} class name here")
            nameBox.setText("")
            nameBox.setMinimumSize(QSize(200, 10))
            nameBox.setSizePolicy(QSizePolicy.Fixed, QSizePolicy.Expanding)

            linkBox = QLineEdit()
            linkBox.setPlaceholderText(f"Enter period {i - 1} zoom link here")
            linkBox.setText("")
            linkBox.setMinimumSize(QSize(500, 10))
            linkBox.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding)

            deleteButton = QPushButton("X")
            deleteButton.setStyleSheet("QPushButton {color: red; font-weight:600;}")
            deleteButton.clicked.connect(lambda: self.removeNewClass(db))
            deleteButton.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding)

            mainGrid.addLayout(timeLayout, i, 0)
            mainGrid.addWidget(nameBox, i, 1)
            mainGrid.addWidget(linkBox, i, 2)
            mainGrid.addWidget(deleteButton, i, 3)

            self.timeBoxes.append((hourBox, minuteBox))
            self.titleBoxes.append(nameBox)
            self.linkBoxes.append(linkBox)

        addButton = QPushButton("Add Class")
        addButton.clicked.connect(lambda: self.addLinkBox(db))
        addButton.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding)
        self.layout.addWidget(addButton)

        self.layout.addLayout(mainGrid, 0, 0)
    
    def deleteLink(self, time, db):
        try:
            db["links"].pop(time)
            db.close()
            self.makeSettingsUI()
        except KeyError:
            self.saveLinks(db, finish=False)
            db["links"].pop(time, None)
            db.close()
            self.makeSettingsUI()
        
    def addLinkBox(self, db):
        if self.saveLinks(db, finish=False):
            self.NEWCLASS = True
            self.makeSettingsUI(db=db)
    
    def removeNewClass(self, db):
        self.NEWCLASS = False
        self.makeSettingsUI(db=db)

    def saveLinks(self, db, finish=True):
        self.TIMES.clear()
        try:
            for hour, minute in self.timeBoxes:
                self.TIMES.append((int(hour.text()), int(minute.text())))
        except ValueError:
            self.alert("Please change the empty time boxes to a valid class time or delete them before proceeding")
            return False
        if len(set(self.TIMES)) < len(self.TIMES):
            self.alert("Uh oh! Looks like you have two classes at the same time. Please fix that before proceeding")
            return False
        links = db["links"]
        links.clear()
        for i in range(len(self.titleBoxes)):
            if (not finish) or finish and (len(self.titleBoxes[i].text() + self.linkBoxes[i].text()) > 0):
                links[self.TIMES[i]] = (self.titleBoxes[i].text(), self.linkBoxes[i].text())
            elif finish:
                self.alert(f"Warning: the class at {self.TIMES[i][0]}:{self.TIMES[i][1]} has no name or link, so it will be deleted")
        if finish:
            self.NEWCLASS = False
            db.close()
            self.makeMainUI()
        return True
    
    def clearLayout(self, layout):
        while layout.count():
            child = layout.takeAt(0)
            if child.widget():
                child.widget().deleteLater()
            elif child.layout():
                self.clearLayout(layout=child.layout())
    
    def alert(self, text):
        alert = QMessageBox()
        alert.setText(text)
        alert.exec_()


if __name__ == '__main__':
    appctxt = ApplicationContext()
    window = MainWindow()
    window.show()
    exit_code = appctxt.app.exec_()
    sys.exit(exit_code)