Load "stdlibcore.ring"
Load "guilib.ring"
Load "transformer.ring"
Load "tokenizer.ring"
Load "config.ring"

New qApp {
    win = new qMainWindow() {
        setWindowTitle("مترجم عربي-إنجليزي")
        setGeometry(100, 100, 800, 600)
        
        # إنشاء الواجهة الرئيسية
        central = new qWidget() {
            setLayout(new qVBoxLayout() {
                # منطقة النص العربي
                addWidget(new qGroupBox() {
                    setTitle("النص العربي")
                    setLayout(new qVBoxLayout() {
                        arabicText = new qPlainTextEdit() {
                            setPlaceholderText("أدخل النص العربي هنا...")
                            setMinimumHeight(150)
                        }
                        addWidget(arabicText)
                    })
                })
                
                # زر الترجمة
                translateBtn = new qPushButton() {
                    setText("ترجم")
                    setStyleSheet("
                        QPushButton {
                            background-color: #4CAF50;
                            color: white;
                            border: none;
                            padding: 10px;
                            font-size: 16px;
                            border-radius: 5px;
                        }
                        QPushButton:hover {
                            background-color: #45a049;
                        }
                    ")
                    setFixedHeight(50)
                    setClickEvent(Method("translate"))
                }
                addWidget(translateBtn)
                
                # منطقة النص الإنجليزي
                addWidget(new qGroupBox() {
                    setTitle("الترجمة الإنجليزية")
                    setLayout(new qVBoxLayout() {
                        englishText = new qPlainTextEdit() {
                            setPlaceholderText("ستظهر الترجمة هنا...")
                            setMinimumHeight(150)
                            setReadOnly(true)
                        }
                        addWidget(englishText)
                    })
                })
                
                # شريط الحالة
                statusLabel = new qLabel() {
                    setText("")
                    setAlignment(Qt_AlignCenter)
                }
                addWidget(statusLabel)
            })
        }
        setCentralWidget(central)
        
        # تحميل النموذج
        oConfig = new TransformerConfig()
        oTransformer = new Transformer(oConfig)
        oTokenizer = new ArabicTokenizer()
        
        # محاولة تحميل آخر نموذج مدرب
        cModelPath = oConfig.cModelDir + "best_model.bin"
        if isFile(cModelPath)
            oTransformer.load(cModelPath)
            statusLabel.setText("تم تحميل النموذج بنجاح")
        else
            statusLabel.setText("تحذير: لم يتم العثور على نموذج مدرب")
        ok
        
        show()
    }
    
    # دالة الترجمة
    func translate
        try {
            # الحصول على النص العربي
            cArabicText = arabicText.toPlainText()
            if len(cArabicText) = 0
                statusLabel.setText("الرجاء إدخال نص للترجمة")
                return
            ok
            
            statusLabel.setText("جاري الترجمة...")
            
            # تجهيز النص
            aTokens = oTokenizer.tokenize(cArabicText)
            
            # الترجمة
            aOutput = oTransformer.translate(aTokens)
            
            # تحويل المخرجات إلى نص
            cEnglishText = oTokenizer.detokenize(aOutput)
            
            # عرض الترجمة
            englishText.setPlainText(cEnglishText)
            statusLabel.setText("تمت الترجمة بنجاح")
            
        catch
            statusLabel.setText("حدث خطأ أثناء الترجمة: " + cCatchError)
        }
    }
    
    exec()
}
