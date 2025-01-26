local QBCore = exports['qb-core']:GetCoreObject()
local toplamaYapiliyor = false
local iptalYapildi = false -- İptal işlemi yapılmış mı kontrolü
local iptalSuresi = 1 -- İptal süresi (ms cinsinden, 10 saniye)
local toplamaSuresi = 5000 -- Kenevir toplama süresi 5 saniye (5000 ms)

-- Toplama yapılacak alanın koordinatları ve yarıçapı
local alanKoordinatlari = vector3(2218.23, 5576.93, 53.79)  -- Alanın merkezi
local alanYaricap = 5.0  -- Alanın yarıçapı (dairesel alan)

Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local pedCoords = GetEntityCoords(ped)

        -- Alanın içine girmeyi kontrol et
        local mesafe = #(pedCoords - alanKoordinatlari)
        if mesafe < alanYaricap then
            sleep = 0
            -- Marker (işaret) ekle
            DrawMarker(1, alanKoordinatlari.x, alanKoordinatlari.y, alanKoordinatlari.z - 0.50, 0.50, 0.50, 0.50, 0.50, 0.50, 0.50, 7.5, 7.5, 1.0, 0, 455, 0, 100, false, true, 2, false, nil, nil, false)
            -- DrawMarker(1, x, y, z, rotX, rotY, rotZ, scaleX, scaleY, scaleZ, r, g, b, alpha, bobUpAndDown, faceCamera, p19, p20, p21, rotate)
            DrawMarker(1, alanKoordinatlari.x, alanKoordinatlari.y, alanKoordinatlari.z - 0.5, 0.0, 0.0, 0.0, 0.0, 12.0, 12.0, 0.5, 0, 255, 0, 100, false, true, 2, false, nil, nil, false)
            -- E tuşu için metin ekleme
            if not toplamaYapiliyor then
                DrawText3D(alanKoordinatlari.x, alanKoordinatlari.y, alanKoordinatlari.z + 1.0, "~g~E~w~ Basarak Kenevir Topla")
                if IsControlJustReleased(0, 38) then -- E tuşu
                    toplamaYapiliyor = true
                    QBCore.Functions.Notify(Config.Mesajlar.ToplamaBaslat, "success")
                    ToplamaOtomatik()
                end
            end
        end

        Citizen.Wait(sleep)
    end
end)

function ToplamaOtomatik()
    local ped = PlayerPedId()

    Citizen.CreateThread(function()
        while toplamaYapiliyor do
            local pedCoords = GetEntityCoords(PlayerPedId())
            local uzaklik = #(pedCoords - alanKoordinatlari)

            -- Alan dışına çıkarsa toplama iptal olur
            if uzaklik > alanYaricap then
                ClearPedTasksImmediately(ped)
                QBCore.Functions.Notify(Config.Mesajlar.AlanDisi, "error")
                toplamaYapiliyor = false
                break
            end

            -- Animasyon ve toplama işlemi
            TaskStartScenarioInPlace(PlayerPedId(), "PROP_HUMAN_BUM_BIN", 0, true)
            QBCore.Functions.Progressbar("kenevir_topla", "Kenevir Topluyorsun...", toplamaSuresi, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {}, {}, {}, function() -- Başarılı toplama
                TriggerServerEvent('qb_weedgather:kenevirVer')
                QBCore.Functions.Notify(Config.Mesajlar.ToplamaTamamlandi, "success")
                
                -- 5 saniye bekledikten sonra yeniden toplama işlemi başlasın
                Citizen.Wait(1) -- 5 saniye bekle
            end)

            Citizen.Wait(toplamaSuresi) -- Toplama süresi kadar bekle
        end
    end)
end

-- 3D metin gösterme fonksiyonu
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

-- Toplama işlemini iptal etmek için tuş (örnek: X tuşu)
local iptalTusu = 73 -- X tuşu (input_key: 73)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if toplamaYapiliyor then
            if IsControlJustReleased(0, iptalTusu) and not iptalYapildi then
                -- İlk iptal işlemi yapılırsa
                iptalYapildi = true
                toplamaYapiliyor = false
                ClearPedTasksImmediately(PlayerPedId())
                QBCore.Functions.Notify(Config.Mesajlar.ToplamaIptal, "error")
                
                -- 10 saniye boyunca tekrar iptal edilmesini engelle
                Citizen.Wait(iptalSuresi)
                iptalYapildi = false -- 10 saniye sonra tekrar iptal yapılabilir
            end
        end
    end
end)

-- Kenevir toplama scripti
RegisterCommand('toplaKenevir', function()
    -- Toplama işlemi
    TriggerEvent('kenevir:topla')

    -- Çıkış işlemi
    Citizen.Wait(3000)  -- 3 saniye bekleyin (işlem süresi)
    print("Kenevir toplama tamamlandı, çıkış yapılıyor...")
    -- Burada çıkış yapmak için gerekli kodu ekleyebilirsiniz.
    -- Eğer çıkış yapmak istiyorsanız, aşağıdaki komutları kullanabilirsiniz:
    -- QBCore.Functions.Notify("Çıkış yapılıyor...", "error")
    -- TriggerServerEvent('qb_weedgather:kenevirVer')  -- Sunucuya gerekli event'i gönderebilirsiniz
end)
