local fs = require "nixio.fs"
local m = Map("nginx-manager",translate("Nginx Manager"), translate("A simple Nginx manager") .. [[<br /><br /><a href="https://github.com/sundaqiang/openwrt-packages" target="_blank">Powered by sundaqiang</a>]])
s = m:section(TypedSection, "nginx", translate("Web site list"))
s.template = "nginx-manager/index"
s.addremove = true
s.anonymous = false
s:tab("general", translate("General Info"))
s:tab("server", translate("Configuration File"))
s:taboption("general", DummyValue, "name", translate("name"))
s:taboption("general", DummyValue, "filepath", translate("File Path"))
file=s:taboption("server", TextValue, "")
file.template = "cbi/tvalue"
file.rows = 25
file.wrap = "off"
file.rmempty = true

function s.create(self,section)
    path="/etc/nginx/conf.d/" .. section .. ".conf"
    fs.copyr("/etc/nginx/conf.d/templates", path)
    TypedSection.create(self,section)
    self.map:set(section, "name", section)
    self.map:set(section, "filepath", path)
    return true
end
function s.remove(self,section)
    path="/etc/nginx/conf.d/" .. section .. ".conf"
    fs.remove(path)
    TypedSection.remove(self,section)
end
function sync_value_to_file(value, file)
	value = value:gsub("\r\n?", "\n")
	local old_value = fs.readfile(file)
	if value ~= old_value then
		fs.writefile(file, value)
	end
end
function file.cfgvalue(self,section)
	return fs.readfile(self.map:get(section, "filepath")) or ""
end
function file.write(self, section, value)
	sync_value_to_file(value, self.map:get(section, "filepath"))
end

s = m:section(SimpleSection, translate("NGINX配置"),translate("本页是配置/etc/config/nginx, 应用保存后自动重启生效."))
s.anonymous=true
if nixio.fs.access("/etc/config/nginx")then
conf=s:option(Value,"nginxconf",nil,translate("开头的数字符号（＃）被视为注释。"))
conf.template="cbi/tvalue"
conf.rows=20
conf.wrap="off"
conf.cfgvalue=function(t,t)
return fs.readfile("/etc/config/nginx")or""
end
conf.write=function(a,a,t)
if t then
t=t:gsub("\r\n?","\n")
fs.writefile("/tmp/nginx",t)
if(luci.sys.call("cmp -s /tmp/nginx /etc/config/nginx")==1)then
fs.writefile("/etc/config/nginx",t)
luci.sys.call("/etc/init.d/nginx restart >/dev/null")
end
fs.remove("/tmp/nginx")
end
end
end
return m
