local encoder = {}
-- ASCII
encoder.ascii = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~¡¢£¤¥¦§¨©ª«¬®¯°±²³´µ¶·¸¹º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿĀāĂăĄąĆćĈĉĊċČčĎďĐđĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħĨĩĪīĬĭĮįİıĲĳĴĵĶķĸĹĺĻļĽľĿŀŁłŃńŅņŇňŉŊŋŌōŎŏŐőŒœŔŕŖŗŘřŚśŜŝŞşŠšŢţŤťŦŧŨũŪūŬŭŮůŰűŲųŴŵŶŷŸŹźŻżŽž"

-- Função para gerar uma chave aleatória
function encoder.genKey(size)
    local result = ""
    for i = 1, size do
        local indiceAleatorio = math.random(#ascii)
        result = result .. ascii:sub(indiceAleatorio, indiceAleatorio)
    end
    return result
end

-- Função para criptografar uma mensagem usando a chave
function encoder.encrypt(message, key)
    local encryptedBuffer = {}
    local keyLength = #key

    for i = 1, #message do
        local charValue = message:byte(i)
        local keyCharValue = key:byte((i - 1) % keyLength + 1)
        local encryptedValue = charValue + keyCharValue
        table.insert(encryptedBuffer, encryptedValue)
    end

    return encryptedBuffer
end

-- Função para descriptografar uma mensagem usando a chave
function encoder.decrypt(encryptedMessage, key)
    local decryptedBuffer = {}
    local keyLength = #key

    for i = 1, #encryptedMessage do
        local charValue = encryptedMessage[i]
        local keyCharValue = key:byte((i - 1) % keyLength + 1)
        local decryptedValue = charValue - keyCharValue
        table.insert(decryptedBuffer, decryptedValue)
    end

    return string.char(unpack(decryptedBuffer))
end

return encoder;