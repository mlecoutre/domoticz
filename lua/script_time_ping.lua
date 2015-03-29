--Initialise la commande de retour finale
commandArray={}
--Mode deboggage (affichage des messages)
debug=true
--Prefixe pour les sorties de log
prefixe="(PING) "
--presence d au moins un peripherique
hasAtLeastOne = false


--Cette fonction calcule la différence de temps (en secondes) entre maintenant
--et la date passée en paramètre.
function timedifference (s)
  year = string.sub(s, 1, 4)
  month = string.sub(s, 6, 7)
  day = string.sub(s, 9, 10)
  hour = string.sub(s, 12, 13)
  minutes = string.sub(s, 15, 16)
  seconds = string.sub(s, 18, 19)
  t1 = os.time()
  t2 = os.time{year=year, month=month, day=day, hour=hour, min=minutes, sec=seconds}
  difference = os.difftime (t1, t2)
  return difference
end



--Tableau des périphériques à "pinguer"
-- Key = adresse ip à pinguer
-- Value = périphérique virtuel à switcher
local ping={}
ping['192.168.0.36']='TelMat'
ping['192.168.0.23']='TelCe'
ping['192.168.0.15']='TelTafCe'
if ((otherdevices['SecuritéArmé']=='On')  and (timedifference(otherdevices_lastupdate['Presence']) > 600)) then
  --pour chaque entree du tableau
  for ip, switch in pairs(ping) do
   --Le Ping ! : -c1 = Un seul ping , -w1 délai d'une seconde d'attente de réponse
   ping_success=os.execute('ping -c1 -w1 '..ip)  

   --Si le ping à epondu
   if ping_success then
     if(debug==true)then print(prefixe.."ping success "..switch) end
     hasAtLeastOne = true
     --si le switch etait sur off on l'allume
     if(otherdevices[switch]=='Off') then
       if(debug==true) then print(prefixe .. ' - Allume swith' .. switch) end 
       commandArray[switch]='On'
     end
   else
      --Si pas de réponse
      if(debug==true) then  print(prefixe.."ping fail "..switch) end
      commandArray[switch]='Off'
   end
  end
  if( hasAtLeastOne == false ) then
   if(debug==true) then  print(prefixe..'Aucun telephone a la maison.') end
    commandArray['Presence'] = 'Off'
  else
    if(debug==true) then print(prefixe .. " - Mise a jour variable de la presence a 'oui'") end 
    commandArray['Presence'] = 'On'
  end
else 
      if(debug==true) then  print(prefixe.."Security unactivated or timediff < 600") end
  
end
