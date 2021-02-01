logger.i('loading status-message')

local drawing = require('hs.drawing')
local geometry = require('hs.geometry')
local screen = require('hs.screen')
local styled_text = require('hs.styledtext')

local status_msg = {}

status_msg.new = function(msg_text, size)
    if size == nil then
        size = 16
    end

    local build_parts = function(msg_text)
        local frame = screen.primaryScreen():frame()
    
        local styled_text_attribs = 
        {
            font = { name = 'SF Mono', size = size },
            paragraphStyle = { alignment = 'center' },
            color = { red = 1.0, green = 1.0, blue = 1.0, alpha = 1.0 }
        }
    
        local text = styled_text.new(msg_text, styled_text_attribs)
    
        local text_size = drawing.getTextDrawingSize(text)

        local text_rect = 
        {
            x = frame.w - text_size.w - 15,
            y = frame.h - text_size.h + 10,
            w = text_size.w + 10,
            h = text_size.h,
        }

        local text = drawing.text(text_rect, text):setAlpha(0.7)
    
        local background = drawing.rectangle(
            {
                x = text_rect.x - 3,
                y = text_rect.y + 3,
                w = text_rect.w,
                h = text_rect.h,
            }
        )

        background:setRoundedRectRadii(5, 5)
        background:setFillColor({ red = .1, green = .1, blue = .1, alpha=1.0 })
    
        return background, text
    end
  
    return {
        _build_parts = build_parts,

        show = function(self)
            self:hide()
  
            self.background, self.text = self._build_parts(msg_text)
            self.background:show()
            self.text:show()
        end,

        hide = function(self)
            if self.background then
                self.background:delete()
                self.background = nil
            end

            if self.text then
                self.text:delete()
                self.text = nil
            end
        end,

        notify = function(self, seconds)
            local seconds = seconds or 1

            self:show()

            hs.timer.delayed.new(seconds, function() self:hide() end):start()
        end
    }
end

return status_msg
