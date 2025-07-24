# فئة طبقة المشفر
Class EncoderLayer {
    # خصائص الطبقة
    nModelDim = 512        # أبعاد النموذج
    nNumHeads = 8          # عدد رؤوس الانتباه
    nFeedForwardDim = 2048 # أبعاد الطبقة الأمامية
    fDropoutRate = 0.1     # معدل الإسقاط
    
    # مكونات الطبقة
    oAttention = null      # طبقة الانتباه متعدد الرؤوس
    oNorm1 = null          # التطبيع الطبقي 1
    oNorm2 = null          # التطبيع الطبقي 2
    oFeedForward = null    # الشبكة العصبية للتغذية الأمامية
    nDModel = 0            # أبعاد النموذج
    
    func init(nP_DModel, nNumHeads, nDFF, fDropout) {
        nDModel = nP_DModel
        
        # تهيئة المكونات
        oAttention = new MultiHeadAttention(nNumHeads, nDModel)
        oNorm1 = new LayerNormalization(nDModel)
        oNorm2 = new LayerNormalization(nDModel)
        oFeedForward = new FeedForward(nDModel, nDFF)
    }
    
    # الخطوة الأمامية
    func forward(x, mask) {
        # طبقة الانتباه مع اتصال متخطي
        att = oAttention.forward(x, x, x, mask)
        out1 = oNorm1.forward(matrix_add(x, att))
        
        # طبقة التغذية الأمامية مع اتصال متخطي
        ff = oFeedForward.forward(out1)
        out2 = oNorm2.forward(matrix_add(out1, ff))
        
        return out2
    }
}

# فئة المشفر الكامل
Class Encoder {
    # خصائص المشفر
    nNumLayers = 6         # عدد الطبقات
    nModelDim = 512        # أبعاد النموذج
    nNumHeads = 8          # عدد رؤوس الانتباه
    nFeedForwardDim = 2048 # أبعاد الطبقة الأمامية
    fDropoutRate = 0.1     # معدل الإسقاط
    
    # مكونات المشفر
    aLayers = []          # طبقات المشفر
    oPositional = null    # الترميز الموضعي
    nNumLayers = 0        # عدد الطبقات
    nDModel = 0           # أبعاد النموذج
    
    func init(nP_NumLayers, nP_DModel, nNumHeads, nDFF, fDropout) {
        nNumLayers = nP_NumLayers
        nDModel = nP_DModel
        
        # تهيئة الترميز الموضعي
        oPositional = new PositionalEncoding(nDModel)
        
        # إنشاء طبقات المشفر
        for i = 1 to nNumLayers {
            add(aLayers, new EncoderLayer(nDModel, nNumHeads, nDFF, fDropout))
        }
    }
    
    # الخطوة الأمامية للمشفر
    func forward(x, mask) {
        # إضافة الترميز الموضعي
        x = oPositional.forward(x, 0)
        
        # تمرير المدخلات عبر كل طبقة
        for layer in aLayers {
            x = layer.forward(x, mask)
        }
        
        return x
    }
}

# فئة الشبكة الأمامية
Class FeedForward {
    # خصائص الشبكة
    nDModel = 0         # أبعاد النموذج
    nDFF = 0            # أبعاد الطبقة الأمامية
    aW1 = null          # مصفوفة الأوزان الأولى
    aW2 = null          # مصفوفة الأوزان الثانية
    aB1 = null          # مصفوفة الإزاحات الأولى
    aB2 = null          # مصفوفة الإزاحات الثانية
    
    func init(nP_DModel, nP_DFF) {
        nDModel = nP_DModel
        nDFF = nP_DFF
        
        # تهيئة المعلمات
        aW1 = matrix_random(nDModel, nDFF)
        aW2 = matrix_random(nDFF, nDModel)
        aB1 = list(nDFF)
        aB2 = list(nDModel)
    }
    
    # الخطوة الأمامية
    func forward(x) {
        # الطبقة الأولى
        h = matrix_multiply(x, aW1)
        for i = 1 to len(h) {
            for j = 1 to nDFF {
                h[i][j] += aB1[j]
                # تطبيق دالة ReLU
                h[i][j] = max(0, h[i][j])
            }
        }
        
        # الطبقة الثانية
        out = matrix_multiply(h, aW2)
        for i = 1 to len(out) {
            for j = 1 to nDModel {
                out[i][j] += aB2[j]
            }
        }
        
        return out
    }
}

# فئة تطبيع الطبقة
Class LayerNormalization {
    # خصائص التطبيع
    nDim = 0             # أبعاد المدخلات
    aGamma = null        # معامل المقياس
    aBeta = null         # معامل الإزاحة
    fEpsilon = 1e-8      # قيمة صغيرة لتجنب القسمة على صفر
    
    func init(nP_Dim) {
        nDim = nP_Dim
        
        # تهيئة معلمات التطبيع
        aGamma = list(nDim)
        aBeta = list(nDim)
        for i = 1 to nDim {
            aGamma[i] = 1
            aBeta[i] = 0
        }
    }
    
    # الخطوة الأمامية
    func forward(x) {
        # حساب المتوسط والانحراف المعياري
        fMean = 0
        fVar = 0
        
        for i = 1 to len(x) {
            for j = 1 to nDim {
                fMean += x[i][j]
            }
        }
        fMean = fMean / (len(x) * nDim)
        
        for i = 1 to len(x) {
            for j = 1 to nDim {
                fVar += pow(x[i][j] - fMean, 2)
            }
        }
        fVar = fVar / (len(x) * nDim)
        
        # تطبيع القيم
        aResult = matrix(len(x), nDim)
        for i = 1 to len(x) {
            for j = 1 to nDim {
                aResult[i][j] = aGamma[j] * (x[i][j] - fMean) / sqrt(fVar + fEpsilon) + aBeta[j]
            }
        }
        
        return aResult
    }
}
