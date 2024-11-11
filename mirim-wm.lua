
-- Codigo de exemplo, coloca 3 e 0.14 na pilha, soma e define como sendo pi

local asm = [[

empurrar_numero     3.00
mpurrar_numero      0.14
adicionar

definir_variavel    pi

puxar_variavel      pi
escrever

]]

local stake = {}  -- Pilha principal
local rom = {}    -- Área da memória protegida somente leitura
local ram = {}    -- Área da memória que o programa pode escrever
local cursor = 0  -- Posição atual do cursor, como Lua começa em 1, o cursor deve começar com 0

-- Conjunto inicial de instruções
local instrucoes = {
    -- Pôe um número no topo da pilha, se não for um número empurre nan
    empurrar_numero =
      function (arg)
        stake[#stake+1] = tonumber(arg) or math.abs(0/0)
      end
    ;
    -- Armazena o valor no topo da pilha na variável
    definir_variavel =
      function (arg)
        ram[arg] = stake[1]
        stake = {} -- Limpa a pilha para evitar lixo
      end
    ;
    -- Pega o valor de uma variável na "RAM"
    puxar_variavel =
      function (arg)
        stake[#stake+1] = ram[arg]
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
