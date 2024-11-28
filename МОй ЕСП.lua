local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local highlightEnabled = false -- Переменная для отслеживания состояния обводки
local highlightList = {} -- Список всех добавленных Highlight
local hintShown = false -- Переменная для отслеживания, была ли показана подсказка
local nameTags = {} -- Список всех меток с никами

-- Функция для добавления Highlight к персонажу
local function addHighlight(character)
    local highlight = Instance.new("Highlight")
    highlight.Adornee = character
    highlight.OutlineColor = Color3.new(1, 0, 0) -- Красный цвет обводки
    highlight.OutlineTransparency = 0 -- Полностью непрозрачная обводка
    highlight.Parent = character
    table.insert(highlightList, highlight) -- Добавляем Highlight в список

    -- Добавляем метку с ником
    local playerNameTag = Instance.new("BillboardGui")
    playerNameTag.Size = UDim2.new(0, 100, 0, 50)
    playerNameTag.Adornee = character.Head
    playerNameTag.AlwaysOnTop = true

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.new(1, 1, 1) -- Белый цвет текста
    nameLabel.TextStrokeTransparency = 0 -- Обводка текста
    nameLabel.Text = character.Name -- Имя персонажа
    nameLabel.Parent = playerNameTag

    playerNameTag.Parent = character.Head -- Привязываем метку к голове персонажа
    table.insert(nameTags, playerNameTag) -- Добавляем метку в список
end

-- Функция для удаления Highlight из персонажа
local function removeHighlight(character)
    for _, highlight in ipairs(highlightList) do
        if highlight.Adornee == character then
            highlight:Destroy()
            table.remove(highlightList, _) -- Удаляем Highlight из списка
            break
        end
    end

    -- Удаляем метку с ником
    for _, nameTag in ipairs(nameTags) do
        if nameTag.Adornee == character.Head then
            nameTag:Destroy()
            table.remove(nameTags, _) -- Удаляем метку из списка
            break
        end
    end
end

-- Обработчик для добавления Highlight при добавлении нового игрока
local function onPlayerAdded(player)
    player.CharacterAdded:Connect(function(character)
        wait(1) -- Ждем, чтобы персонаж успел загрузиться
        if highlightEnabled then
            addHighlight(character)
        end
    end)

    -- Если персонаж уже существует (например, при перезагрузке)
    if player.Character then
        if highlightEnabled then
            addHighlight(player.Character)
        end
    end
end

-- Подключаем обработчик для всех существующих игроков
for _, player in ipairs(Players:GetPlayers()) do
    onPlayerAdded(player)
end

-- Подключаем обработчик для новых игроков
Players.PlayerAdded:Connect(onPlayerAdded)

-- Обработчик нажатия клавиши W для показа подсказки
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if not gameProcessedEvent and input.KeyCode == Enum.KeyCode.W then
        -- Показываем подсказку только один раз при нажатии W
        if not hintShown then
            showHint("Нажмите U чтобы включить или выключить ESP") -- Показываем подсказку
            hintShown = true -- Устанавливаем флаг, что подсказка была показана
        end
    elseif not gameProcessedEvent and input.KeyCode == Enum.KeyCode.U then
        highlightEnabled = not highlightEnabled -- Переключаем состояние обводки
        
        if highlightEnabled then
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character then
                    addHighlight(player.Character) -- Добавляем Highlight к персонажу
                end
            end
        else
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character then
                    removeHighlight(player.Character) -- Удаляем Highlight из персонажа
                end
            end
        end
    end
end)

print("Обводка и ники для других игроков активированы!")
