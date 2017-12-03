---------------------------------
--Script to calculate duration and distance between two points using Google Maps
--Author   : woody4165 based on Neutrino Traffic with Waze, updated by G3rard
--Date     : 9 April 2016 
---------------------------------
commandArray={}

time = os.date("*t")
day = tonumber(os.date("%w"))

--idx of devices for capturing the travel minutes in both direction
idxtraffic='4'
idxroute='5'
--usual traveltime (mins)
usualtimehomework = 45
usualtimeworkhome = 45
-- Coordinates starting point -  , 
fromx="50.7809383"
fromy="1.6110201"
-- Coordinates destination point , 
tox="51.024638"
toy="2.297095"
--Google Api Key
key='AIzaSyAjE7QiR_88dJENABJvI93jaYw9tjQyRhU'

--determine workday (Mo-Fri)
if (day > 0 and day < 6) then
    week=true; weekend=false
else
    week=false; weekend=true
end

--determine time (7:00-9:00, 16:00-19:00)
if ((time.hour > 6 and time.hour < 9) or (time.hour == 9 and time.min < 1)) then
    mattina=true; sera=false
elseif ((time.hour > 15 and time.hour < 19) or (time.hour == 19 and time.min < 1)) then
    mattina=false; sera=true
else
    mattina=false; sera=false
end


--calculate traveltime
function traveltime(fromx,fromy,tox,toy)
    --import JSON.lua library
    json = (loadfile "/home/pi/domoticz/scripts/lua/JSON.lua")()

    -- get data from Google Maps and decode it in gmaps
    local jsondata    = assert(io.popen('curl "https://maps.googleapis.com/maps/api/directions/json?origin='..fromx..','..fromy..'&destination='..tox..','..toy..'&departure_time=now&key='..key..'"'))
    local jsondevices = jsondata:read('*all')
    jsondata:close()
    local gmaps = json:decode(jsondevices)

    -- Read from the data table, and extract duration and distance in text
    distance = gmaps.routes[1].legs[1].distance.text
    duration = gmaps.routes[1].legs[1].duration_in_traffic.text
    summary = gmaps.routes[1].summary
    mins=0
    -- mins is only the number part of duration (for evaulation purpose or to return a number in a number device)
    for minutes in string.gmatch(duration, "%d+") do mins = tonumber(minutes) end
    return mins
end

--weekday (Mo-Fri) and time between 7:00-9:00
if (week and mattina) then
    --every 15 minutes
    if((time.min % 15)==0) then
        traffic=traveltime(fromx,fromy,tox,toy)
        message=tostring(traffic)..'min pour se rendre au travail '..("%02d:%02d"):format(time.hour, time.min)..' percorso '..tostring(summary)
      print(message)
      --send message if traveltime is longer than usual
      if(traffic > usualtimehomework) then
       -- os.execute('curl --data chat_id=xxxxxxxx --data-urlencode "text='..message..'"  "https://api.telegram.org/botxxxxxxxxxxxxx/sendMessage" ')
          commandArray['SendNotification']=message
      end
        --return a text to the device (eg. 12 mins)
        commandArray[1]={['UpdateDevice'] =idxtraffic..'|0|' .. tostring(traffic)}
        commandArray[2]={['UpdateDevice'] =idxroute..'|0|' .. tostring(message)}
    end

--weekday (Mo-Thu) and time between 16:00-19:00
elseif (week and sera) then
    --every 15 minutes
    if((time.min % 15)==0) then
        traffic=traveltime(tox,toy,fromx,fromy)
        message=tostring(traffic)..'min pour aller a la maison '..("%02d:%02d"):format(time.hour, time.min)..' percorso '..tostring(summary)
      print(message)
      --send message if traveltime is longer than usual
--      if(traffic > usualtimeworkhome) then
--        os.execute('curl --data chat_id=xxxxxx --data-urlencode "text='..message..'"  "https://api.telegram.org/botxxxxxxxxx/sendMessage" ')
--          commandArray['SendNotification']=message
--      end
        --return a text to the device (eg. 12 mins)
        commandArray[1]={['UpdateDevice'] =idxtraffic..'|0|' .. tostring(traffic)}
        commandArray[2]={['UpdateDevice'] =idxroute..'|0|' .. tostring(message)}

    end
else
    -- set device to 0 to prevent device get the last value after working hour
    zero=0
    commandArray[1]={['UpdateDevice'] =idxtraffic..'|0|' .. tostring(zero)}
    commandArray[2]={['UpdateDevice'] =idxroute..'|0|' .. tostring(zero)}
end

return commandArray
