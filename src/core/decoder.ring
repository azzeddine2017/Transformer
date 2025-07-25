# Decoder Implementation for Transformer
Load "stdlibcore.ring"
Load "matrix.ring"
Load "transformer.ring"
Load "encoder.ring"

# فئة طبقة فك التشفير - FastPro Optimized
Load "fastpro.ring"
Class DecoderLayer{
    # مكونات الطبقة
    oSelfAttention      # طبقة الانتباه الذاتي
    oCrossAttention     # طبقة الانتباه المتقاطع
    oNorm1             # التطبيع الطبقي 1
    oNorm2             # التطبيع الطبقي 2
    oNorm3             # التطبيع الطبقي 3
    oFeedForward       # الشبكة العصبية للتغذية الأمامية
    nDModel            # أبعاد النموذج
    
    func init(nP_DModel, nNumHeads, nDFF, fDropout){
        nDModel = nP_DModel
        
        # تهيئة المكونات
        oSelfAttention = new MultiHeadAttention(nNumHeads, nDModel)
        oCrossAttention = new MultiHeadAttention(nNumHeads, nDModel)
        oNorm1 = new LayerNormalization(nDModel)
        oNorm2 = new LayerNormalization(nDModel)
        oNorm3 = new LayerNormalization(nDModel)
        oFeedForward = new FeedForward(nDModel, nDFF)
    }    
    func forward(x, encOutput, srcMask, tgtMask ){
        # الانتباه الذاتي
        att1 = oSelfAttention.forward(x, x, x, tgtMask)
        out1 = oNorm1.forward(matrix_add(x, att1))
        
        # الانتباه المتقاطع
        att2 = oCrossAttention.forward(out1, encOutput, encOutput, srcMask)
        out2 = oNorm2.forward(matrix_add(out1, att2))
        
        # التغذية الأمامية
        ff = oFeedForward.forward(out2)
        out3 = oNorm3.forward(matrix_add(out2, ff))
        
        return out3
    }
}
# فئة فك التشفير الكامل
Class Decoder {
    # مكونات فك التشفير
    aLayers = []        # طبقات فك التشفير
    oPositional         # الترميز الموضعي
    oEmbedding         # طبقة التضمين
    nNumLayers         # عدد الطبقات
    nDModel            # أبعاد النموذج
    nVocabSize         # حجم المفردات
    
    func init(nP_NumLayers, nP_DModel, nP_VocabSize, nNumHeads, nDFF, fDropout){
        nNumLayers = nP_NumLayers
        nDModel = nP_DModel
        nVocabSize = nP_VocabSize
        
        # تهيئة الترميز الموضعي والتضمين
        oPositional = new PositionalEncoding(nDModel)
        oEmbedding = new Embedding(nVocabSize, nDModel)
        
        # إنشاء طبقات فك التشفير
        for i = 1 to nNumLayers
            add(aLayers, new DecoderLayer(nDModel, nNumHeads, nDFF, fDropout))
        next
    }   
    func forward(x, encOutput, srcMask, tgtMask){
        # تطبيق التضمين والترميز الموضعي
        x = oEmbedding.forward(x)
        x = oPositional.forward(x, 0)
        
        # تمرير المدخلات عبر كل طبقة
        for layer in aLayers
            x = layer.forward(x, encOutput, srcMask, tgtMask)
        next
        
        return x 
    }
}
# طبقة التضمين
Class Embedding {
    nVocabSize
    nDModel
    aEmbedding
    
    func init(nP_VocabSize, nP_DModel){
        nVocabSize = nP_VocabSize
        nDModel = nP_DModel
        
        # تهيئة مصفوفة التضمين
        aEmbedding = matrix_random(nVocabSize, nDModel)
}
    func forward(x){
        # تحويل المدخلات إلى تضمينات
        aResult = matrix(len(x), nDModel)
        for i = 1 to len(x)
            for j = 1 to nDModel
                aResult[i][j] = aEmbedding[x[i]][j]
            next
        next
        
        return aResult
    }       
}
# طبقة الترميز الموضعي
Class PositionalEncoding {
    nDModel
    aPositional
    
    func init(nP_DModel){
        nDModel = nP_DModel
        
        # تهيئة مصفوفة الترميز الموضعي
        aPositional = matrix(nDModel, nDModel)
    }    
    func forward(x, pos){
        # تطبيق الترميز الموضعي
        aResult = matrix(len(x), nDModel)
        for i = 1 to len(x)
            for j = 1 to nDModel
                aResult[i][j] = x[i][j] + aPositional[pos][j]
            next
        next
        
        return aResult
    }
}
# طبقة الانتباه الذاتي
Class MultiHeadAttention{
    nNumHeads
    nDModel
    aWeights
    
    func init(nP_NumHeads, nP_DModel){
        nNumHeads = nP_NumHeads
        nDModel = nP_DModel
        
        # تهيئة مصفوفة الأوزان
        aWeights = matrix(nDModel, nDModel)
    }   
    func forward(q, k, v, mask){
        # تحويل المدخلات إلى رؤوس الانتباه
        aQ = matrix(len(q), nDModel)
        aK = matrix(len(k), nDModel)
        aV = matrix(len(v), nDModel)
        
        # تطبيق الانتباه الذاتي - FastPro Optimized
        # Use FastPro for efficient attention computation
        aScores = updateList(aQ, :mul, :matrix, updateList(aK, :transpose, :matrix))
        aScores = updateList(aScores, :scalardiv, :matrix, sqrt(nDModel))
        aAttn = updateList(aScores, :softmax, :matrix)
        aResult = updateList(aAttn, :mul, :matrix, aV)

        return aResult
    }
# طبقة التطبيع الطبقي
Class LayerNormalization {
    nDModel
    aWeights
    
    func init(nP_DModel){
        nDModel = nP_DModel
        
        # تهيئة مصفوفة الأوزان
        aWeights = matrix(nDModel, nDModel)
    }    
    func forward(x){
        # تطبيق التطبيع الطبقي
        aResult = matrix(len(x), nDModel)
        for i = 1 to len(x)
            for j = 1 to nDModel
                aResult[i][j] = x[i][j] / sqrt(aWeights[i][j])
            next
        next
        
        return aResult
    }
}
# طبقة التغذية الأمامية
Class FeedForward {
    nDModel
    nDFF
    aWeights
    
    func init(nP_DModel, nP_DFF){
        nDModel = nP_DModel
        nDFF = nP_DFF
        
        # تهيئة مصفوفة الأوزان
        aWeights = matrix(nDModel, nDFF)
        
    }    
    func forward(x){
        # تطبيق التغذية الأمامية
        aResult = matrix(len(x), nDFF)
        for i = 1 to len(x)
            for j = 1 to nDFF
                aResult[i][j] = 0
                for k = 1 to nDModel
                    aResult[i][j] += x[i][k] * aWeights[k][j]
                next
            next
        next
        
        return aResult
    }
}
Class Transformer { 
    # المتغيرات العامة
    nSrcVocabSize = 0
    nTgtVocabSize = 0
    nDModel = 512
    nNumHeads = 8
    nNumEncoderLayers = 6
    nNumDecoderLayers = 6
    nDFF = 2048
    
    oEncoder = null
    oDecoder = null
    oSrcEmbed = null
    oTgtEmbed = null
    oFinalLayer = null
    
    func init(nP_SrcVocabSize, nP_TgtVocabSize, nP_DModel, 
             nP_NumHeads, nP_NumEncoderLayers, 
             nP_NumDecoderLayers, nP_DFF){
        
        nSrcVocabSize = nP_SrcVocabSize
        nTgtVocabSize = nP_TgtVocabSize
        nDModel = nP_DModel
        nNumHeads = nP_NumHeads
        nNumEncoderLayers = nP_NumEncoderLayers
        nNumDecoderLayers = nP_NumDecoderLayers
        nDFF = nP_DFF
        
        # إنشاء طبقات التضمين
        oRandom = new Random()
        oSrcEmbed = oRandom.xavier_init(nSrcVocabSize, nDModel)
        oTgtEmbed = oRandom.xavier_init(nTgtVocabSize, nDModel)
        
        # إنشاء المشفر والمفكك
        oEncoder = new Encoder(nNumEncoderLayers, nDModel, nNumHeads, nDFF)
        oDecoder = new Decoder(nTgtVocabSize, nDModel, nNumHeads, nNumDecoderLayers, nDFF)
        
        # طبقة الإخراج النهائية
        oFinalLayer = oRandom.xavier_init(nDModel, nTgtVocabSize)
    }
    func forward(oSrcTokens, oTgtTokens, oSrcMask, oTgtMask){
        # تضمين المدخلات
        oSrcEmbedded = oSrcTokens.multiply(oSrcEmbed)
        oTgtEmbedded = oTgtTokens.multiply(oTgtEmbed)
        
        # تشفير المدخلات
        oEncOutput = oEncoder.forward(oSrcEmbedded, oSrcMask)
        
        # فك تشفير المخرجات
        oDecOutput = oDecoder.forward(oTgtEmbedded, oEncOutput, 
                                    oSrcMask, oTgtMask)
        
        # التحويل النهائي
        return oDecOutput.multiply(oFinalLayer)
    }
    func generate(oSrcTokens, nMaxLength, oTokenizer){
        # توليد الترجمة
        oSrcEmbedded = oSrcTokens.multiply(oSrcEmbed)
        oEncOutput = oEncoder.forward(oSrcEmbedded)
        
        # بدء التوليد برمز البداية
        oCurrentOutput = new Matrix(1, 1)
        oCurrentOutput.set(1, 1, oTokenizer.aSpecialTokens["<BOS>"])
        
        aGeneratedTokens = [oCurrentOutput.get(1, 1)]
        
        # توليد الرموز حتى نصل إلى رمز النهاية أو الحد الأقصى للطول
        while len(aGeneratedTokens) < nMaxLength
            # تضمين المخرجات الحالية
            oTgtEmbedded = oCurrentOutput.multiply(oTgtEmbed)
            
            # فك التشفير
            oDecOutput = oDecoder.forward(oTgtEmbedded, oEncOutput)
            
            # التنبؤ بالرمز التالي
            oLogits = oDecOutput.multiply(oFinalLayer)
            oProbabilities = new Activations().softmax(oLogits)
            
            # اختيار الرمز الأعلى احتمالاً
            nNextToken = 0
            nMaxProb = -1
            for i = 1 to oProbabilities.nCols
                if oProbabilities.get(1, i) > nMaxProb
                    nMaxProb = oProbabilities.get(1, i)
                    nNextToken = i
                ok
            next
            
            add(aGeneratedTokens, nNextToken)
            
            # التحقق من رمز النهاية
            if nNextToken = oTokenizer.aSpecialTokens["<EOS>"]
                exit
            ok
            
            # تحديث المخرجات الحالية
            oNewOutput = new Matrix(1, len(aGeneratedTokens))
            for i = 1 to len(aGeneratedTokens)
                oNewOutput.set(1, i, aGeneratedTokens[i])
            next
            oCurrentOutput = oNewOutput
        end
        
        return aGeneratedTokens
    }
}
    