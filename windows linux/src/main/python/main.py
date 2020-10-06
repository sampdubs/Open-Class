
from fbs_runtime.application_context.PyQt5 import ApplicationContext
from PyQt5.QtWidgets import *
from PyQt5.QtGui import *
from PyQt5.QtCore import *

import sys
import webbrowser
import shelve
from datetime import datetime

class MainWindow(QWidget):
    def __init__(self):
        super().__init__()

        self.TIMES = [(8, 30), (8, 50), (10, 15), (12, 10), (13, 35)]

        self.layout = QGridLayout()
        self.setGeometry(100, 100, 600, 400)
        self.setLayout(self.layout)
        self.makeMainUI()

    def makeMainUI(self):
        self.clearLayout(self.layout)
        db = shelve.open("links")
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


    def makeSettingsUI(self):
        self.clearLayout(self.layout)
        db = shelve.open("links", writeback=True)
        links = db["links"]
        self.titleBoxes = []
        self.linkBoxes = []
        i = 0
        mainGrid = QGridLayout()

        submitButton = QPushButton("Done")
        submitButton.clicked.connect(lambda: self.saveLinks(db))
        submitButton.setSizePolicy(QSizePolicy.Fixed, QSizePolicy.Fixed)

        nameTitle = QLabel("Class Name")
        # nameTitle.setSizePolicy(QSizePolicy.Fixed, QSizePolicy.Fixed)
        linkTitle = QLabel("Link to Class Zoom")
        linkTitle.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding)

        mainGrid.addWidget(submitButton, 0, 0, 1, 1, Qt.AlignLeft | Qt.AlignTop)
        mainGrid.addWidget(nameTitle, 1, 1)
        mainGrid.addWidget(linkTitle, 1, 2)

        i = 2
        for time in links:
            linkLabel = QLabel(f"{time[0]}:{time[1]}")

            nameBox = QLineEdit()
            nameBox.setPlaceholderText(f"Enter period {i - 1} class name here")
            nameBox.setText(links[time][0])
            nameBox.setMinimumSize(QSize(200, 10))
            nameBox.setSizePolicy(QSizePolicy.Fixed, QSizePolicy.Fixed)

            linkBox = QLineEdit()
            linkBox.setPlaceholderText(f"Enter period {i - 1} zoom link here")
            linkBox.setText(links[time][1])
            linkBox.setMinimumSize(QSize(500, 10))
            linkBox.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding)

            # deleteButton = QPushButton("Delete link")
            # deleteButton.clicked.connect(self.makeFunction(self.deleteLink, (i, db)))
            # deleteButton.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding)
            
            mainGrid.addWidget(linkLabel, i, 0)
            mainGrid.addWidget(nameBox, i, 1)
            mainGrid.addWidget(linkBox, i, 2)

            self.titleBoxes.append(nameBox)
            self.linkBoxes.append(linkBox)
            i += 1

        # addButton = QPushButton("Add")
        # addButton.clicked.connect(lambda: self.addLinkBox(db))
        # addButton.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding)
        # addButton.setFont(QFont("Arial", 64))

        self.layout.addLayout(mainGrid, 0, 0)
    
    # def deleteLink(self, i, db):
    #     if i < len(db["links"]):
    #         db["links"].pop(i)
    #         db.close()
    #         self.makeSettingsUI()
    #     else:
    #         self.saveLinks(db, finish=False)
    #         db["links"].pop(i)
    #         db.close()
    #         self.makeSettingsUI()

    # def addLinkBox(self, db):
    #     i = len(self.titleBoxes)
    #     linkLabel = QLabel("Quick Link #{}".format(i + 1))
    #     linkLabel.setFont(QFont("Arial", 32))
    #     titleBox = QLineEdit()
    #     titleBox.setPlaceholderText("Enter the name of this link")
    #     titleBox.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding)
    #     titleBox.setFont(QFont("Arial", 32))
    #     linkBox = QLineEdit()
    #     linkBox.setPlaceholderText("Enter the link")
    #     linkBox.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding)
    #     linkBox.setFont(QFont("Arial", 32))
    #     deleteButton = QPushButton("Delete link")
    #     deleteButton.clicked.connect(self.makeFunction(self.deleteLink, (i, db)))
    #     deleteButton.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding)
    #     deleteButton.setFont(QFont("Arial", 32))
    #     gLayout = self.layout.children()[0].children()[0]
    #     gLayout.addWidget(linkLabel, i, 0)
    #     gLayout.addWidget(titleBox, i, 1)
    #     gLayout.addWidget(linkBox, i, 2)
    #     gLayout.addWidget(deleteButton, i, 3)
    #     self.titleBoxes.append(titleBox)
    #     self.linkBoxes.append(linkBox)

        
    
    def saveLinks(self, db, finish=True):
        links = db["links"]
        for i in range(len(self.titleBoxes)):
            if i < len(links):
                links[self.TIMES[i]] = (self.titleBoxes[i].text(), self.linkBoxes[i].text())
            # elif self.titleBoxes[i].text() != "" and self.linkBoxes[i].text() != "":
            #     links.append((self.titleBoxes[i].text(), self.linkBoxes[i].text()))
        if finish:
            db.close()
            self.makeMainUI()
    
    def clearLayout(self, layout):
        while layout.count():
            child = layout.takeAt(0)
            if child.widget():
                child.widget().deleteLater()
            elif child.layout():
                self.clearLayout(layout=child.layout())


if __name__ == '__main__':
    appctxt = ApplicationContext()
    window = MainWindow()
    window.show()
    exit_code = appctxt.app.exec_()
    sys.exit(exit_code)