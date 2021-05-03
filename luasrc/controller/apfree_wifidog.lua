-- Copyright (C) 2016 zhangzf@kunteng.org
-- Licensed to the public under the GNU General Public License v3.

module("luci.controller.apfree_wifidog", package.seeall)

function index()
	-- entry({"admin", "services", "apfreeWifiDog"}, cbi("apfree_wifidog"), _("WifiDog"), 40).index = true
	-- entry({"admin", "services", "apfreeWifiDog", "getClientList"}, call("getClientList"))
	-- entry({"admin", "services", "apfreeWifiDog", "getClientList"}, call("getClientList"))


	 entry({"admin", "new_tab"}, firstchild(), "New tab", 60).dependent=false  --this adds the top level tab and defaults to the first sub-tab (tab_from_cbi), also it is set to position 30
     entry({"admin", "new_tab", "tab_from_cbi"}, cbi("apfree_wifidog"), "CBI Tab", 1)  --this adds the first sub-tab that is located in <luci-path>/luci-myapplication/model/cbi and the file is called cbi_tab.lua, also set to first position
     entry({"admin", "new_tab", "tab_from_view"}, template("view_tab"), "View Tab", 2)  --this adds the second sub-tab that is located in <luci-path>/luci-myapplication/view and the file is called view_tab.htm, also set to the second position

end

function getClientList()
	local RespDate = {}
	local RespCode = 0
	local HostName, IPAddr, MacAddr, Download, Upload, LoginTime
	
	local WdctlCMD = "wdctl status | grep -e '^ ' | sed -r 's/^ +//' 2>/dev/null"
	
	local UpTime = luci.util.exec("wdctl status | grep Uptime | cut -d ' ' -f 2-6")
	if UpTime == "" then
		RespCode = 1
	else		
		local function initDate()
			HostName = "unknow"
			IPAddr = "" 
			MacAddr = "" 
			Download = 0 
			Upload = 0
			LoginTime = "0"
		end
		
		local ClientList = {}
		for _, Line in pairs(luci.util.execl(WdctlCMD)) do	
			if Line:match('^(IP:)') == "IP:" then
				IPAddr, MacAddr = Line:match('^IP: (%S+) MAC: (%S+)')
			elseif Line:match('^(First Login:)') == "First Login:" then
				LoginTime = Line:match('^First Login: (%d+)')
			elseif Line:match('^(Name:)') == "Name:" then
				HostName = Line:match('^Name: (%S+)')		
			elseif Line:match('^(Downloaded:)') == "Downloaded:" then
				Download = Line:match('^Downloaded: (%d+)')		
			elseif Line:match('^(Uploaded:)') == "Uploaded:" then
				Upload = Line:match('^Uploaded: (%d+)')
				
				table.insert(ClientList, {
						['hostname'] = HostName,
						['ipaddr'] = IPAddr,
						['macaddr'] = MacAddr,
						['download'] = Download,
						['upload'] = Upload,
						['logintime'] = os.difftime(os.time(), tonumber(LoginTime) or 0),
					})
					
				initDate()
			end
		end
		
		RespDate["clients"] = ClientList
		RespDate["uptime"]	= UpTime
	end
	
	RespDate["code"] = RespCode
	luci.http.prepare_content("application/json")
	luci.http.write_json(RespDate)
end