

local asm = [[

empurrar_numero     0
definir_variavel    contador

:loop
  empurrar_numero    1
  puxar_variavel     contador
  adicionar

  definir_variavel   contador

  puxar_variavel     contador
  escrever
  empurrar_numero    10
  igual
  inverter

condicionar
ir_para loop

]]


local stake = {}
local rom = {}
local ram = {}

local cursor = 0
local pularProxima = false
local instrucoes = {
    empurrar_numero =
      function (arg)
        stake[#stake+1] = tonumber(arg) or math.abs(0/0)
      end
    ;
    empurrar_texto =
      function (arg)
        stake[#stake+1] = arg
      end
    ;
    definir_variavel =
      function (arg)
        ram[arg] = stake[1]
        stake = {}
      end
    ;
    puxar_variavel =
      function (arg)
        stake[#stake+1] = ram[arg]
      end
    ;
    adicionar =
      function ()
        local result = 0
        for i = #stake, 1, -1 do
            result = result+stake[i]
        end
        stake = {}
        stake[1] = result
      end
    ;
    igual =
      function ()
        local result = stake[1] == stake[2]
        stake = {}
        stake[1] = result
      end
    ;
    inverter =
      function ()
        stake[1] = not stake[1]
      end
    ;
    condicionar =
      function ()
        pularProxima = not stake[1]
        stake = {}
      end
    ;
    ir_para =
      function (arg)
        cursor = rom[arg:sub(1,-1)]
      end
    ;
    escrever =
      function ()
        print(table.unpack(stake))
      end
    ;
}

for linha in asm:gmatch("[^\n]+") do
    linha = linha:gsub("\r",""):gsub("^[%s]*","")
    rom[#rom+1] = linha
    if linha:sub(1,1) == ":" then
        rom[linha:sub(2,-1)] = #rom
    end
end

while cursor < #rom do
    cursor = cursor+1
    local instrucao = rom[cursor]:gsub("[%s].*","")
    local argumento = rom[cursor]:gsub("^.*[%s]+","")
    if pularProxima then
        pularProxima = false
    elseif instrucao:sub(1,1) ~= ":" and instrucao:sub(1,2) ~= "--" then
        local funcao = instrucoes[instrucao]
        if not funcao then
            error("Instrução desconhecida próximo a linha "..cursor.." => '"..instrucao.."'")
        end
        instrucoes[instrucao](argumento)
    end
end
