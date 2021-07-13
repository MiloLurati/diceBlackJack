classdef DiceBlackJack_GUI < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                    matlab.ui.Figure
        DICEBLACKJACKLabel          matlab.ui.control.Label
        MoneyEditFieldLabel         matlab.ui.control.Label
        MoneyEditField              matlab.ui.control.NumericEditField
        BetEditFieldLabel           matlab.ui.control.Label
        BetEditField                matlab.ui.control.NumericEditField
        PlayerstatusEditFieldLabel  matlab.ui.control.Label
        PlayerstatusEditField       matlab.ui.control.EditField
        DealerstatusEditFieldLabel  matlab.ui.control.Label
        DealerstatusEditField       matlab.ui.control.EditField
        QuitButton                  matlab.ui.control.Button
        TerminalEditField           matlab.ui.control.EditField
        Image                       matlab.ui.control.Image
        Image2                      matlab.ui.control.Image
        StartButton                 matlab.ui.control.Button
        ThrowButton                 matlab.ui.control.Button
    end

    
    properties (Access = public)
        money % Tot money of player
        bet % current hand bet
        wait % waiting for input or action
        hand % player hand
        dealerHand % dealer hand
        rollAgain 
        end_ % for main while loop
    end
    
    methods (Access = public)
        
        function waitForAction(app)
            app.wait = 0;
            while app.wait ~= 1
                pause(2);
            end
            app.wait = 0;
        end
        
        function main(app)
            vid = videoinput('winvideo',1);
            start(vid);
            app.end_ = "next";
            app.MoneyEditField.Editable = 'On';
            app.TerminalEditField.Value = "Enter money";
            app.waitForAction();
            app.MoneyEditField.Editable = 'Off';
            while app.end_ == "next" & app.money > 0
                app.hand = 0;
                app.TerminalEditField.Value = "Enter bet";
                app.BetEditField.Editable = 'On';
                app.waitForAction();
                app.BetEditField.Editable = 'Off';
                for i = 1:2 
                    app.TerminalEditField.Value = "You can roll your dice";
                    app.TerminalEditField.Value = "Press throw after you have rolled the dice";
                    app.waitForAction();
                    im = getsnapshot(vid);
                    n = countDots(im);
                    app.hand = app.hand + 2 * n;
                    app.TerminalEditField.Value = "You are at: " + app.hand;
                    app.PlayerstatusEditField.Value = "You are at: " + app.hand;
                end
                app.TerminalEditField.Value = "Do you want to roll again?[next/stop]";
                pause(2);
                app.TerminalEditField.Value = "Listening ...";
                app.rollAgain = "noise";
                app.TerminalEditField.Value = "Listening ...";
                while app.rollAgain == "noise"
                    app.rollAgain = recognize_word();
                    app.TerminalEditField.Value = "I did not understad, could you please repeat again";
                end
                if app.rollAgain == "next"
                    while app.rollAgain == "next"
                        app.TerminalEditField.Value = "You can roll your dice"; 
                        app.TerminalEditField.Value = "Press throw after you have rolled the dice";
                        app.waitForAction();
                        im=getsnapshot(vid);
                        n = countDots(im);
                        app.hand = app.hand + n;
                        app.TerminalEditField.Value = "You are at: " + app.hand;
                        app.PlayerstatusEditField.Value = "You are at: " + app.hand;
                        if app.hand > 21
                            break;
                        end
                        app.TerminalEditField.Value = "Do you want to roll again?[next/stop]";
                        pause(2);
                        app.TerminalEditField.Value = "Listening ...";
                        app.rollAgain = recognize_word();
                        if app.rollAgain ~= "next"
                            break;
                        end
                    end
                end
        
                app.TerminalEditField.Value = "Now is my turn";
                pause(2);
                app.dealerHand = 0;
                firstHandDealer = 1;
                while app.dealerHand <= 18
                    r = randperm(6);
                    if firstHandDealer == 1
                        app.dealerHand = (r(1) + r(2)) * 2;
                        firstHandDealer = 0;
                    else
                        app.dealerHand = app.dealerHand + r(1);
                    end
                end
                app.TerminalEditField.Value = "I have " + app.dealerHand; 
                app.DealerstatusEditField.Value = "I have " + app.dealerHand;
        
                if app.dealerHand > 21 & app.hand <= 21
                    app.TerminalEditField.Value = "You win this hand!";
                    app.money = app.money + app.bet;
                    app.MoneyEditField.Value = double(app.money);
                elseif app.hand > 21
                    app.TerminalEditField.Value = "I win this hand!";
                    app.money = app.money - app.bet;
                    app.MoneyEditField.Value = double(app.money);
                elseif app.dealerHand < app.hand
                    app.TerminalEditField.Value = "You win this hand!";
                    app.money = app.money + app.bet;
                    app.MoneyEditField.Value = double(app.money);
                elseif app.dealerHand > app.hand
                    app.TerminalEditField.Value = "I win this hand!";
                    app.money = app.money - app.bet;
                    app.MoneyEditField.Value = app.money;
                else 
                    app.TerminalEditField.Value = "It's a tie!";
                end
                pause(3);
                app.TerminalEditField.Value = "Do you want to play again?[next/stop]";
                pause(2);
                app.end_ = "noise";
                app.TerminalEditField.Value = "Listening ...";
                while app.end_ == "noise"
                    app.end_ = recognize_word();
                    app.TerminalEditField.Value = "I did not understad, could you please repeat again";
                end
                if app.money <= 0
                    app.TerminalEditField.Value = "You do not have enough money to play again";
                end
                app.BetEditField.Value = 0;
                app.PlayerstatusEditField.Value = "";
                app.DealerstatusEditField.Value = "";
            end
            app.TerminalEditField.Value = "Bye bye";
    
            stop(vid);
            delete(vid);
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: QuitButton
        function QuitButtonPushed(app, event)
            app.delete;
        end

        % Button pushed function: StartButton
        function StartButtonPushed(app, event)
            app.main();
            
        end

        % Value changed function: MoneyEditField
        function MoneyEditFieldValueChanged(app, event)
            app.wait = 1;
            value = app.MoneyEditField.Value;
            app.money = value;
        end

        % Value changed function: BetEditField
        function BetEditFieldValueChanged(app, event)
            app.wait = 1;
            value = app.BetEditField.Value;
            app.bet = value;
        end

        % Value changed function: TerminalEditField
        function TerminalEditFieldValueChanged(app, event)
            value = app.TerminalEditField.Value;
            
        end

        % Value changed function: PlayerstatusEditField
        function PlayerstatusEditFieldValueChanged(app, event)
            value = app.PlayerstatusEditField.Value;
            
        end

        % Value changed function: DealerstatusEditField
        function DealerstatusEditFieldValueChanged(app, event)
            value = app.DealerstatusEditField.Value;
            
        end

        % Button pushed function: ThrowButton
        function ThrowButtonPushed(app, event)
            app.wait = 1;
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Color = [0.9412 0.9412 0.9412];
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'UI Figure';

            % Create DICEBLACKJACKLabel
            app.DICEBLACKJACKLabel = uilabel(app.UIFigure);
            app.DICEBLACKJACKLabel.HorizontalAlignment = 'center';
            app.DICEBLACKJACKLabel.FontName = 'Baskerville Old Face';
            app.DICEBLACKJACKLabel.FontSize = 20;
            app.DICEBLACKJACKLabel.FontWeight = 'bold';
            app.DICEBLACKJACKLabel.Position = [229 426 184 25];
            app.DICEBLACKJACKLabel.Text = 'DICE BLACK JACK';

            % Create MoneyEditFieldLabel
            app.MoneyEditFieldLabel = uilabel(app.UIFigure);
            app.MoneyEditFieldLabel.HorizontalAlignment = 'right';
            app.MoneyEditFieldLabel.Position = [447 366 42 22];
            app.MoneyEditFieldLabel.Text = 'Money';

            % Create MoneyEditField
            app.MoneyEditField = uieditfield(app.UIFigure, 'numeric');
            app.MoneyEditField.ValueChangedFcn = createCallbackFcn(app, @MoneyEditFieldValueChanged, true);
            app.MoneyEditField.Position = [504 366 100 22];

            % Create BetEditFieldLabel
            app.BetEditFieldLabel = uilabel(app.UIFigure);
            app.BetEditFieldLabel.HorizontalAlignment = 'right';
            app.BetEditFieldLabel.Position = [464 334 25 22];
            app.BetEditFieldLabel.Text = 'Bet';

            % Create BetEditField
            app.BetEditField = uieditfield(app.UIFigure, 'numeric');
            app.BetEditField.ValueChangedFcn = createCallbackFcn(app, @BetEditFieldValueChanged, true);
            app.BetEditField.Position = [504 334 100 22];

            % Create PlayerstatusEditFieldLabel
            app.PlayerstatusEditFieldLabel = uilabel(app.UIFigure);
            app.PlayerstatusEditFieldLabel.HorizontalAlignment = 'right';
            app.PlayerstatusEditFieldLabel.Position = [414 300 75 22];
            app.PlayerstatusEditFieldLabel.Text = 'Player status';

            % Create PlayerstatusEditField
            app.PlayerstatusEditField = uieditfield(app.UIFigure, 'text');
            app.PlayerstatusEditField.ValueChangedFcn = createCallbackFcn(app, @PlayerstatusEditFieldValueChanged, true);
            app.PlayerstatusEditField.Editable = 'off';
            app.PlayerstatusEditField.HorizontalAlignment = 'right';
            app.PlayerstatusEditField.Position = [504 300 100 22];

            % Create DealerstatusEditFieldLabel
            app.DealerstatusEditFieldLabel = uilabel(app.UIFigure);
            app.DealerstatusEditFieldLabel.HorizontalAlignment = 'right';
            app.DealerstatusEditFieldLabel.Position = [414 268 76 22];
            app.DealerstatusEditFieldLabel.Text = 'Dealer status';

            % Create DealerstatusEditField
            app.DealerstatusEditField = uieditfield(app.UIFigure, 'text');
            app.DealerstatusEditField.ValueChangedFcn = createCallbackFcn(app, @DealerstatusEditFieldValueChanged, true);
            app.DealerstatusEditField.Editable = 'off';
            app.DealerstatusEditField.HorizontalAlignment = 'right';
            app.DealerstatusEditField.Position = [505 268 100 22];

            % Create QuitButton
            app.QuitButton = uibutton(app.UIFigure, 'push');
            app.QuitButton.ButtonPushedFcn = createCallbackFcn(app, @QuitButtonPushed, true);
            app.QuitButton.Position = [56 279 100 22];
            app.QuitButton.Text = 'Quit';

            % Create TerminalEditField
            app.TerminalEditField = uieditfield(app.UIFigure, 'text');
            app.TerminalEditField.ValueChangedFcn = createCallbackFcn(app, @TerminalEditFieldValueChanged, true);
            app.TerminalEditField.Editable = 'off';
            app.TerminalEditField.HorizontalAlignment = 'center';
            app.TerminalEditField.FontSize = 20;
            app.TerminalEditField.FontWeight = 'bold';
            app.TerminalEditField.BackgroundColor = [0.9412 0.9412 0.9412];
            app.TerminalEditField.Position = [18 81 608 149];

            % Create Image
            app.Image = uiimage(app.UIFigure);
            app.Image.Position = [447 387 100 100];
            app.Image.ImageSource = 'dicesImageGUI.png';

            % Create Image2
            app.Image2 = uiimage(app.UIFigure);
            app.Image2.Position = [102 387 100 100];
            app.Image2.ImageSource = 'dicesImageGUI.png';

            % Create StartButton
            app.StartButton = uibutton(app.UIFigure, 'push');
            app.StartButton.ButtonPushedFcn = createCallbackFcn(app, @StartButtonPushed, true);
            app.StartButton.Position = [56 321 100 22];
            app.StartButton.Text = 'Start';

            % Create ThrowButton
            app.ThrowButton = uibutton(app.UIFigure, 'push');
            app.ThrowButton.ButtonPushedFcn = createCallbackFcn(app, @ThrowButtonPushed, true);
            app.ThrowButton.Position = [56 366 100 22];
            app.ThrowButton.Text = 'Throw';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = DiceBlackJack_GUI

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end