class IntroEventScene < EventScene
    TITLE_START_LOGO = "logo"
    SPLASH_IMAGES = ["splash2"]
    SECONDS_PER_SPLASH = 8

    def initialize(viewport = nil)
        super(viewport)
        @pic = addImage(0, 0, "")
        @pic.setOpacity(0, 0) # set opacity to 0 after waiting 0 frames
        @pic2 = addImage(0, 0, "") # flashing "Press Enter" picture
        @pic2.setOpacity(0, 0)
        @pic3 = addImage(0, 0, "") # logo
        @pic3.setOpacity(0, 0)
        # set opacity to 0 after waiting 0 frames
        @index = 0
        if SPLASH_IMAGES.empty?
            open_title_screen(self, nil)
        else
            open_splash(self, nil)
        end
    end

    def open_title_screen(_scene, *args)
        onUpdate.clear
        onCTrigger.clear
        @pic.name = "Graphics/Titles/" + TITLE_BG_IMAGE
        @pic.moveOpacity(0, FADE_TICKS, 255)
        @pic3.name = "Graphics/Titles/" + TITLE_START_LOGO
        @pic3.setXY(0, -62.5, 0)
        @pic3.setVisible(0, true)
        @pic2.name = "Graphics/Titles/" + TITLE_START_IMAGE
        @pic2.setXY(0, TITLE_START_IMAGE_X, TITLE_START_IMAGE_Y)
        @pic2.setVisible(0, true)
        @pic2.moveOpacity(0, FADE_TICKS, 255)
        pictureWait
        pbBGMPlay($data_system.title_bgm)
        onUpdate.set(method(:title_screen_update)) # called every frame
        onCTrigger.set(method(:close_title_screen)) # called when C key is pressed
    end
end

class HallOfFame_Scene
    ENTRY_WAIT_TIME = 1.0
    # Wait time (in seconds) when showing "Welcome to the Hall of Fame!".
    WELCOME_WAIT_TIME = 2.0

    def writeTrainerData
        totalsec = $stats.play_time.to_i
        hour = totalsec / 60 / 60
        min = totalsec / 60 % 60
        pubid = sprintf("%05d", $player.public_ID)
        lefttext = _INTL("Name<r>{1}", $player.name) + "<br>"
        lefttext += _INTL("ID No.<r>{1}", pubid) + "<br>"
        if hour > 0
            lefttext += _INTL("Time<r>{1}h {2}m", hour, min) + "<br>"
        else
            lefttext += _INTL("Time<r>{1}m", min) + "<br>"
        end
        @sprites["messagebox"] = Window_AdvancedTextPokemon.new(lefttext)
        @sprites["messagebox"].viewport = @viewport
        @sprites["messagebox"].width = 192 if @sprites["messagebox"].width < 192
        @sprites["msgwindow"] = pbCreateMessageWindow(@viewport)
        pbMessageDisplay(@sprites["msgwindow"],
                         _INTL("Welcome, new Frontier Brain!") + "\\^")
    end
end
