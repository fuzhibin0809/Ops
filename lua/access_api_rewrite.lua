if string.find(ngx.var.request_uri,"/project/[._0-9a-zA-Z]+/.*") then
	branch = string.gsub(ngx.var.request_uri,"/project/","")
	branch = string.gsub(branch,"/.*","")
	shell = "echo project_"..branch.."| sha1sum | awk '{print $1}' | tr a-z A-Z | /usr/bin/bc |awk '{print 1substr($0,0,4)}'"
	file = io.popen(shell)
	port = file:read("*line")
	file:close()
	ngx.var.apibranch = "127.0.0.1:"..port
end
