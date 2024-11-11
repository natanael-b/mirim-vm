
-- Empurra 2 numeros iguais e realiza comparações

local asm = [[

empurrar_numero     2
empurrar_numero     2

escrever

inverter
escrever

condicionar
empurrar_numero     3
]]

local stake = {}           -- Pilha principal
local rom = {}             -- Área da memória protegida somente leitura
local ram = {}             -- Área da memória que o programa pode escrever
local cursor = 0           -- Posição atual do cursor, como Lua começa em 1, o cursor deve começar com 0
local pularProxima = false -- se verdadeiro, pula a proxima linha na leitura da "ROM"

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
    -- Compara os dois valores no topo da pilha são igual
    igual =
      function ()
        local result = stake[1] == stake[2]
        stake = {}
        stake[1] = result -- Limpa a pilha para evitar lixo
      end
    ;
    -- Inverte o valor no topo da pilha
    inverter =
      function ()
        stake[1] = not stake[1]
      end
    ;
    -- Só permite a execução da próxima linha se o primeiro valor no topo da pilha for verdadeiro
    condicionar =
      function ()
        pularProxima = not stake[1]
        stake = {} -- Limpa a pilha para evitar lixo
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

    if pularProxima then
        -- restaura o estado de pularProxima se pular a linha atual
        pularProxima = false
    else
        instrucoes[instrucao](argumento)
    end
end
