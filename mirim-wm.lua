
-- Codigo de exemplo, soma 3 com 2 e imprime o resultado

local asm = [[

empurrar_numero     3
empurrar_numero     2
adicionar
escrever

]]

local stake = {}  -- Pilha principal
local rom = {}    -- Área da memória protegida somente leitura
local cursor = 0  -- Posição atual do cursor, como Lua começa em 1, o cursor deve começar com 0

-- Conjunto inicial de instruções
local instrucoes = {
    -- Pôe um número no topo da pilha, se não for um número empurre nan
    empurrar_numero =
      function (arg)
        stake[#stake+1] = tonumber(arg) or math.abs(0/0)
      end
    ;
    -- Adiciona os valores da pilha
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
    -- Escreve o conteúdo da pilha
    escrever =
      function ()
        print(table.unpack(stake))
      end
    ;
}

-- Transcreve o código sanitizado para a ROM
for linha in asm:gmatch("[^\n]+") do
    linha = linha:gsub("\r",""):gsub("^[%s]*","")
    rom[#rom+1] = linha
end

-- Itera linha a linha na ROM
while cursor < #rom do
    cursor = cursor+1
    -- Intrução é o que vem antes do primeiro espaço
    local instrucao = rom[cursor]:gsub("[%s].*","")
    -- Argumento é o que vem depois cada instrução ou tem um argumento ou tem nenhum
    local argumento = rom[cursor]:gsub("^.*[%s]","")
    local funcao = instrucoes[instrucao]
    if not funcao then
        error("Instrução desconhecida próximo a linha "..cursor.." => '"..instrucao.."'")
    end
    instrucoes[instrucao](argumento)
end
