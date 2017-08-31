if string.find(ngx.var.request_uri,"^/project/.*") then
        uri=string.gsub(ngx.var.request_uri,"^/project/","")
        web_branch=string.gsub(uri,"/.*","")

        uri=string.gsub(ngx.var.request_uri,"^.*/api/","")
        product_name=string.gsub(uri,"/.*","")

        shell="sed -e 's/ //g' -e 's/\"//g' -e 's/:/\\//g' -e 's/,//g' /data/app/web/project/"..web_branch.."/api_mapping.json|grep "..product_name
        file = io.popen(shell)
        uri_api = file:read("*line")
        file:close()
        ngx.var.api_uri="/"..uri_api.."/"..ngx.var.api_uri
        ngx.req.set_uri(ngx.var.api_uri)
end
