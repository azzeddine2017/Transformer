Load "stdlibcore.ring"
Load "guilib.ring"
Load "chat_session.ring"
Load "../utils/globals.ring"

# المتغيرات العامة
app
oChat

Class ChatWindow
    win
    layout
    chatDisplay
    inputText
    sendButton
    switchButton
    clearButton
    saveButton
    oSession
    cCurrentLang = "ar"
    
    func init
        oSession = new ChatSession()
        setupUI()
        
    func setupUI
        win = new qWidget() {
            setWindowTitle("نظام المحادثة العربية-الإنجليزية")
            setMinimumWidth(600)
            setMinimumHeight(400)
            
            layout = new qVBoxLayout() {
                
                # منطقة عرض المحادثة
                chatDisplay = new qTextEdit() {
                    setReadOnly(true)
                    setStyleSheet("
                        QTextEdit {
                            background-color: #f5f5f5;
                            border: 1px solid #ddd;
                            border-radius: 5px;
                            padding: 10px;
                            font-size: 14px;
                        }
                    ")
                }
                addWidget(chatDisplay)
                
                # منطقة الإدخال والأزرار
                inputLayout = new qHBoxLayout() {
                    inputText = new qLineEdit() {
                        setPlaceholderText("اكتب رسالتك هنا...")
                        setStyleSheet("
                            QLineEdit {
                                padding: 5px;
                                border: 1px solid #ddd;
                                border-radius: 3px;
                                font-size: 14px;
                            }
                        ")
                    }
                    addWidget(inputText)
                    
                    sendButton = new qPushButton("إرسال") {
                        setStyleSheet("
                            QPushButton {
                                background-color: #4CAF50;
                                color: white;
                                border: none;
                                padding: 5px 15px;
                                border-radius: 3px;
                            }
                            QPushButton:hover {
                                background-color: #45a049;
                            }
                        ")
                    }
                    addWidget(sendButton)
                }
                addLayout(inputLayout)
                
                # شريط الأدوات
                toolLayout = new qHBoxLayout() {
                    switchButton = new qPushButton("تبديل اللغة") {
                        setStyleSheet("
                            QPushButton {
                                background-color: #2196F3;
                                color: white;
                                border: none;
                                padding: 5px 15px;
                                border-radius: 3px;
                            }
                            QPushButton:hover {
                                background-color: #1976D2;
                            }
                        ")
                    }
                    addWidget(switchButton)
                    
                    clearButton = new qPushButton("مسح المحادثة") {
                        setStyleSheet("
                            QPushButton {
                                background-color: #f44336;
                                color: white;
                                border: none;
                                padding: 5px 15px;
                                border-radius: 3px;
                            }
                            QPushButton:hover {
                                background-color: #d32f2f;
                            }
                        ")
                    }
                    addWidget(clearButton)
                    
                    saveButton = new qPushButton("حفظ المحادثة") {
                        setStyleSheet("
                            QPushButton {
                                background-color: #FF9800;
                                color: white;
                                border: none;
                                padding: 5px 15px;
                                border-radius: 3px;
                            }
                            QPushButton:hover {
                                background-color: #F57C00;
                            }
                        ")
                    }
                    addWidget(saveButton)
                }
                addLayout(toolLayout)
            }
            
            setLayout(layout)
        }
        
        # ربط الإشارات
        QObject.connect(sendButton, "clicked()", Method(:sendMessage))
        QObject.connect(inputText, "returnPressed()", Method(:sendMessage))
        QObject.connect(switchButton, "clicked()", Method(:switchLanguage))
        QObject.connect(clearButton, "clicked()", Method(:clearChat))
        QObject.connect(saveButton, "clicked()", Method(:saveChat))
        
    func show
        win.show()
        
    func sendMessage
        cText = inputText.text()
        if len(cText) = 0 return ok
        
        # تحديد لغات الترجمة
        if cCurrentLang = "ar"
            cFromLang = "ar"
            cToLang = "en"
        else
            cFromLang = "en"
            cToLang = "ar"
        ok
        
        # إضافة الرسالة للعرض
        addMessageToDisplay(cText, cCurrentLang, "user")
        
        # الترجمة
        cTranslation = oSession.translate(cText, cFromLang, cToLang)
        addMessageToDisplay(cTranslation, cToLang, "assistant")
        
        # مسح حقل الإدخال
        inputText.setText("")
        
    func addMessageToDisplay(cText, cLang, cRole)
        if cRole = "user"
            cPrefix = if cLang = "ar" "أنت: " else "You: " ok
            cColor = "#2196F3"
        else
            cPrefix = if cLang = "ar" "المساعد: " else "Assistant: " ok
            cColor = "#4CAF50"
        ok
        
        chatDisplay.append("
            <div style='
                margin: 5px;
                padding: 8px;
                border-radius: 5px;
                background-color: " + cColor + "22;
                color: " + cColor + ";
            '>
                <strong>" + cPrefix + "</strong>
                <span style='color: #333;'>" + cText + "</span>
            </div>
        ")
        
    func switchLanguage
        if cCurrentLang = "ar"
            cCurrentLang = "en"
            inputText.setPlaceholderText("Type your message here...")
            sendButton.setText("Send")
            switchButton.setText("Switch Language")
            clearButton.setText("Clear Chat")
            saveButton.setText("Save Chat")
        else
            cCurrentLang = "ar"
            inputText.setPlaceholderText("اكتب رسالتك هنا...")
            sendButton.setText("إرسال")
            switchButton.setText("تبديل اللغة")
            clearButton.setText("مسح المحادثة")
            saveButton.setText("حفظ المحادثة")
        ok
        
    func clearChat
        chatDisplay.clear()
        oSession = new ChatSession()
        
    func saveChat
        cFileName = QFileDialog.getSaveFileName(
            win,
            "حفظ المحادثة",
            "",
            "Text Files (*.txt)"
        )
        
        if len(cFileName) > 0
            try
                fp = fopen(cFileName, "w")
                
                for oMessage in oSession.aHistory
                    cLine = oMessage.timestamp + " [" +
                           oMessage.role + "/" + oMessage.lang + "] " +
                           oMessage.text + nl
                           
                    fputs(fp, cLine)
                next
                
                fclose(fp)
                
                msgBox("تم حفظ المحادثة بنجاح!")
                
            catch
                msgBox("حدث خطأ أثناء حفظ المحادثة: " + cCatchError)
            end
        ok
        
    func msgBox(cText)
        mb = new qMessageBox(win) {
            setText(cText)
            show()
        }

func main
    app = new qApp {
        oChat = new ChatWindow()
        oChat.show()
        exec()
    }

# تشغيل البرنامج
main()
