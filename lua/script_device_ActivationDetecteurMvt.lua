--Mode deboggage (affichage des messages)
debug=true
prefixe = '(MOTION) '

 commandArray = {}
 if (debug == true) then print(prefixe .. 'Declenchement script detecteur de mvt') end
 --for i, v in pairs(devicechanged) do print(i, v) end

 if (otherdevices['ActivationDetecteurMvt'] == 'On') then
   if ( otherdevices['Presence'] == "On" ) then
      print(prefixe .. 'Presence Mat et/ou ce')
   else
     if (debug ==true) then print(prefixe .. 'ALERTE INTRUSION') end
     commandArray['SendNotification']='ALERTE INTRUSION#Detection Mvt sans presence mat et ce#1'
--     commandArray['SendEmail']='ALERTE INTRUSION#Detection Mvt sans presence mat et ce#mlecoutre@gmail.com'
   end
end
