require "json"

class Bridge
  JSON.mapping(
    id: String,
    internalipaddress: String,
    macaddress: String?,
    name: String?
  )
end
