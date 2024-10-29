/*
  ******************************************************************************
  MIKROCOMPUTER LABOR - HOME-STATION

  THOMAS LANER, 11807845

  In diesem Projekt gilt:
  *=============================================================================
  *        SYSCLK(Hz)                             | 64000000
  *-----------------------------------------------------------------------------
  *        AHB Prescaler                          | 1
  *-----------------------------------------------------------------------------
  *        APB2 Prescaler                         | 1
  *-----------------------------------------------------------------------------
  *        APB1 Prescaler                         | 2
  *=============================================================================
  ******************************************************************************
*/
#include "stm32f30x_conf.h"

//function definitions
void init_led_matrix(void);                                                             /*! used to inizalize led_matrix according to data sheet*/

//constants
const int PRESCALE_VALUE = 63999;
const int TIMER_PERIOD = 100;
const int amount_of_fields_per_matrix = 8;

//variables
uint32_t calibration_value = 0;                                                         /*! Var for ADC calibration value */
uint16_t ADC_input[2] = {0, 0};                                                         /*! Var to store incoming ADC data */
uint16_t player_points = 0;
                          /*!x  y*/
uint8_t player_pos[2] =     {8,32};                                                     /*! maximum value: 8, 32*/
int movement_direction[2] = {0,0};                                                      /*! contains the players current movement direction */

                        /*!x_1 y_1 x_2 y_2*/
uint8_t goal_pos[2][2]   = {{0,0} , {0,1}};                                             /*! maximum value: 8,32*/

int game_init = 1;                                                                      /*!used to indicate that the game is starting for the first time*/
uint8_t current_led_matrix[4][8] = {{0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00}, {0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00}, {0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00}, {0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00}};
int button_released = 1;
int main(void)
{
    //definitions
    
        GPIO_InitTypeDef GPIO_InitStructure;                                            /*!struktur in der Parameter für die config von Peripherien (LED_MATRIX, BUTTON_B) gespeichert werden */
        
        TIM_TimeBaseInitTypeDef TIM_TimeBaseInitStructure;                              /*!struktur in der Parameter für die config des Timers gespeichert wird */
        NVIC_InitTypeDef NVIC_InitStructure;                                            /*!struktur in der Parameter für die config des NVIC gespeichert wird */
        NVIC_PriorityGroupConfig(NVIC_PriorityGroup_2);                                 /*!nvic priorität setzen -> in diesem fall 2 bit für gruppe und subgruppe*/
        
        USART_InitTypeDef  USART_InitStructure;                                         /*!struktur mit der die USART konfiguriert wird */
    
        ADC_CommonInitTypeDef    ADC_CommonInitStructure;                               /*!struktur mit der alle ADS's gleichzeitig konfiguriert werden */
        ADC_InitTypeDef          ADC_InitStructure;                                     /*!struktur mit der einzelne ADC's konfiguriert werden */
				
        SPI_InitTypeDef SPI_InitStructure;
        DMA_InitTypeDef  DMA_InitStructure;
            
    //LED_MATRIX config
    
        //GPIOA aktivieren
        RCC_AHBPeriphClockCmd(RCC_AHBPeriph_GPIOA, ENABLE);                             /*!aktivieren durch versorgen des ports mit Takt */

        //config der Modes
        GPIO_InitStructure.GPIO_Mode = GPIO_Mode_OUT;                                   /*!output*/
        GPIO_InitStructure.GPIO_OType = GPIO_OType_OD;                                  /*!im open-drain betrieb betreiben, da Steuerleitungen (MOSI, CLK, CS) mit Pull-Up-Widerständen versehen sind */
        GPIO_InitStructure.GPIO_Pin = GPIO_Pin_4;
        GPIO_InitStructure.GPIO_PuPd = GPIO_PuPd_NOPULL;
        GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
        
        //erstellte Struktur auf GPIO-Pin-A schreiben
        GPIO_Init(GPIOA, &GPIO_InitStructure);
    
    
    //JOYSTICK config
        
        //config der Modes
        GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AN;                                    /*!analoger Modus des controllers */
        GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;
        GPIO_InitStructure.GPIO_Pin = GPIO_Pin_0 | GPIO_Pin_1;                          /*!0 x_direction, 1: y_direction */
        GPIO_InitStructure.GPIO_PuPd = GPIO_PuPd_NOPULL;
        GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
    
        //erstellte Struktur auf GPIO-Pin-A schreiben
        GPIO_Init(GPIOA, &GPIO_InitStructure);
        
    
    //BUTTON_B config
    
        //GPIOB aktivieren
        RCC_AHBPeriphClockCmd(RCC_AHBPeriph_GPIOB, ENABLE);                             /*!aktivieren durch versorgen des ports mit Takt */
        
        //config der Modes
        GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IN;                                    /*!input */
        GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;                                  /*!mit push-pull betreiben da mit pull-up-widerständen (wenn ein schalter 0 -> alle 0) versehen und low-active */
        GPIO_InitStructure.GPIO_Pin = GPIO_Pin_3;
        GPIO_InitStructure.GPIO_PuPd = GPIO_PuPd_NOPULL;
        GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
        
        GPIO_Init(GPIOB, &GPIO_InitStructure);                                          /*!write struct to GPIO-Pin-B */
    
    
    //UART config
    
        //config der Pins welche mit UART verbunden werden (GPIOA ist bereits in Zeile 40 aktiviert worden)
    
            GPIO_InitStructure.GPIO_Mode=GPIO_Mode_AF;
            GPIO_InitStructure.GPIO_OType=GPIO_OType_PP;
            GPIO_InitStructure.GPIO_Pin=GPIO_Pin_2;                                     /*!only using PIN_2 (= STM32 -> P), since data is only written */
            GPIO_InitStructure.GPIO_PuPd=GPIO_PuPd_NOPULL;
            GPIO_InitStructure.GPIO_Speed=GPIO_Speed_50MHz;
            
            //erstellte Struktur auf GPIO-Pin-A schreiben und somit Pins config
            GPIO_Init(GPIOA, &GPIO_InitStructure);
        
            //richtige AF für Pin wählen damit er mit UART verbunden ist
            GPIO_PinAFConfig(GPIOA, GPIO_PinSource2, GPIO_AF_7);

        //UART selbst config
    
            //UART aktivieren
            RCC_APB1PeriphClockCmd(RCC_APB1Periph_USART2, ENABLE);
            
            //Wertzuweisung der UART struktur
            USART_InitStructure.USART_BaudRate=9600;                                      // TODO: Baudrate ok?
            USART_InitStructure.USART_WordLength=USART_WordLength_8b;                     /*! Datenbits = 8 ("Wortlänge")  */
            USART_InitStructure.USART_StopBits=USART_StopBits_1;                          /*! Stopbits = 1  */
            USART_InitStructure.USART_Parity=USART_Parity_No;                             /*! kein Paritybit  */
            USART_InitStructure.USART_HardwareFlowControl=USART_HardwareFlowControl_None; /*! keine Hardware Flow Control  */
            USART_InitStructure.USART_Mode=USART_Mode_Tx;                                 /*! aktivieren von TX  */
            
            //erstellte Struktur auf USART2 schreiben und somit USART config
            USART_Init(USART2, &USART_InitStructure);
            
            // UART starten
            USART_Cmd(USART2, ENABLE);
    
    
    //TIMER config
        
        //Timer aktivieren
        RCC_APB1PeriphClockCmd(RCC_APB1Periph_TIM2, ENABLE);                            /*!aktivieren durch versorgen des timers mit Takt  */

        TIM_TimeBaseStructInit(&TIM_TimeBaseInitStructure);                             /*!configsstruktur des timers mit standardwerten füllen  */
      
        TIM_TimeBaseInitStructure.TIM_Prescaler=PRESCALE_VALUE;                         /*!timer_takt = sysclk/ (prescaler + 1) = 64000000/64000 = 1000Hz  */
        TIM_TimeBaseInitStructure.TIM_Period= TIMER_PERIOD;                             /*!clk = 1/(timer_takt * timer_periode) = 1/1kHz = 0.1sec  */
        
        TIM_TimeBaseInit(TIM2,&TIM_TimeBaseInitStructure);                              /*!erstellte Struktur auf TIM2 schreiben  */
    
				TIM_ITConfig(TIM2, TIM_IT_Update, ENABLE);
		
    //ADC config
    
        //takt des adc config
        RCC_AHBPeriphClockCmd(RCC_AHBPeriph_ADC12, ENABLE);                             /*!takt für ADC freigeben  */
        RCC_ADCCLKConfig(RCC_ADC12PLLCLK_OFF);                                          /*!takt ist vom AHB Bus zu erhalten und nicht von der PLL  */
        
        //common struktur config
        ADC_CommonStructInit(&ADC_CommonInitStructure);                                 /*!standardwerte einstellen  */
        ADC_CommonInitStructure.ADC_Clock = ADC_Clock_SynClkModeDiv1;                   /*!ahb als taktquelle für adc nutzen  */
        ADC_CommonInitStructure.ADC_DMAMode = ADC_DMAMode_Circular;                     /*!ahb als taktquelle für DMA nutzen */
        ADC_CommonInit(ADC1, &ADC_CommonInitStructure);
    
        //zu verwendender adc1 config
        ADC_StructInit(&ADC_InitStructure);                                             /*!standardwerte einstellen */
        ADC_InitStructure.ADC_ContinuousConvMode = ADC_ContinuousConvMode_Enable;       /*!kontinuierliches messen aktivieren */
        ADC_InitStructure.ADC_OverrunMode = ADC_OverrunMode_Enable;                     /*!wert des adc wird kontinuierlich erneurt, auch wenn er noch nicht gelesen wurde */
        ADC_Init(ADC1, &ADC_InitStructure);                                             /*!struktur übergeben */
    
        //festlegen der zu lesenden channel
        //TODO: sample time ok? " Wirw‰hlen hier 61.5 Takte, da der Temperatursensor laut Datasheet (PDF, S 103, Kapitel 6.3.23) mindestens 2us Sampling Time benˆtigt"
        //TODO: channel ok? nicht festgelegt?
        ADC_RegularChannelConfig(ADC1, ADC_Channel_1, 1, ADC_SampleTime_61Cycles5);     /*!1: zu configder ADC, 2: welchen Channel in die Channel_Sequence einfügen */
        ADC_RegularChannelConfig(ADC1, ADC_Channel_2, 2, ADC_SampleTime_61Cycles5);     /*!3: an welche Stelle der Channel sequence soll channel stehen, 4: sample time des channels */
        ADC_RegularChannelSequencerLengthConfig(ADC1,2);                                /*!anzahl der channel in channel sequence liste angeben */
    
        
        //voltage regulator
        ADC_VoltageRegulatorCmd(ADC1, ENABLE);                                          /*!voltage regulator aktivieren */
        
        TIM_Cmd(TIM2, ENABLE);                                                          /*!vorbereiteten timer nutzen um benötigte zeit abzuwarten (interrupt wird momentan gesetzt aber kein interrupt channel aufgerufen) -> timer starten */
        TIM_ClearITPendingBit(TIM2,TIM_IT_Update);                                      /*!interrupt flag zurücksetzen (wird beim start sofort einmal gesetzt) */
    
        while(TIM_GetFlagStatus(TIM2,TIM_IT_Update)==0){                                /*!warten bis interrupt -> 0.1sec >> benötigte 10µs */
            //wait
        };
    
        TIM_Cmd(TIM2, DISABLE);                                                         /*!timer wieder deaktivieren */
        TIM_ClearITPendingBit(TIM2,TIM_IT_Update);                                      /*!pendig bit zurücksetzen */
        NVIC_ClearPendingIRQ(TIM2_IRQn);                                                /*!interrupt channel flag zurücksetzen (sonst wird es beim aktivieren des channel sofort aufgerufen) */
        
        //kalibrierung des ADC
        ADC_SelectCalibrationMode(ADC1, ADC_CalibrationMode_Single);                    /*!zum bestimmen der kalibrierung des ADC */
        ADC_StartCalibration(ADC1);                                                     /*!start der kalibrierung */
        while(ADC_GetCalibrationStatus(ADC1) != RESET );                                /*!warten bis kalibrierung fertig (hier existiert flag) */
        calibration_value = ADC_GetCalibrationValue(ADC1);                              /*!4 ADC Takte warten (ref.man) durch auslesen des erzeugten kalibrierungswertes */
    
        //ADC starten
        ADC_Cmd(ADC1, ENABLE);
        while(!ADC_GetFlagStatus(ADC1, ADC_FLAG_RDY));                                  /*!flag existing */
        ADC_StartConversion(ADC1);                                                      /*!start adc's process */
    
    //DMA config
    
        RCC_AHBPeriphClockCmd(RCC_AHBPeriph_DMA1, ENABLE);
        
        DMA_InitStructure.DMA_PeripheralBaseAddr = (uint32_t) &ADC1->DR;                /*! regular data register of ADC*/
        DMA_InitStructure.DMA_MemoryBaseAddr = (uint32_t) &ADC_input;                   /*! address of var in which incoming data is saved */
        DMA_InitStructure.DMA_DIR = DMA_DIR_PeripheralSRC;                              /*! since source is peripheral (adc) */
        DMA_InitStructure.DMA_BufferSize = 2;                                           /*!  */
        DMA_InitStructure.DMA_PeripheralInc = DMA_PeripheralInc_Disable;                /*! default value - would increase address of the periph. reg */
        DMA_InitStructure.DMA_MemoryInc = DMA_MemoryInc_Enable;                         /*! don't increase address of memory reg (ADC_input) */
        DMA_InitStructure.DMA_PeripheralDataSize = DMA_PeripheralDataSize_HalfWord;     /*! ADC reports = 12b << hw (16b)*/
        DMA_InitStructure.DMA_MemoryDataSize = DMA_MemoryDataSize_HalfWord;             /*! halfword = 2 bytes */
        DMA_InitStructure.DMA_Mode = DMA_Mode_Circular;                                 /*! for continuous data flow */
        DMA_InitStructure.DMA_Priority = DMA_Priority_High;
        DMA_InitStructure.DMA_M2M = DMA_M2M_Disable;                                    /*! must be disabled in circ. mode (ref. manual: p. 187) */

        DMA_Init(DMA1_Channel1, &DMA_InitStructure);

        //activate adc and dma
        ADC_DMAConfig(ADC1, ADC_DMAMode_Circular);                                      /*! select between one shot DMA mode and circular DMA mode */
        ADC_DMACmd(ADC1, ENABLE);                                                       /*! activate ADC */
        DMA_Cmd(DMA1_Channel1, ENABLE);                                                 /*! enable DMA channel of ADC */
    
    
    //SPI config
        
        //config der Modes
        GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AF;
        GPIO_InitStructure.GPIO_OType = GPIO_OType_OD;                                  /*!since SPI_CLK, MOSI... are configured as pull-up -> OD */
        GPIO_InitStructure.GPIO_Pin = GPIO_Pin_5 | GPIO_Pin_7;                          /*!PA5: SPI_CLK, PA7:SPI_MOSI  */
        GPIO_InitStructure.GPIO_PuPd = GPIO_PuPd_NOPULL;
        GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
        GPIO_Init(GPIOA, &GPIO_InitStructure);
        
        //AF config (auswählen der korrekten AF -> SPI / AF_5)
        GPIO_PinAFConfig(GPIOA, GPIO_PinSource5, GPIO_AF_5);
        GPIO_PinAFConfig(GPIOA, GPIO_PinSource7, GPIO_AF_5);
        
        //clk der spi aktivieren
        RCC_APB2PeriphClockCmd(RCC_APB2Periph_SPI1, ENABLE);
        
        SPI_I2S_DeInit(SPI1);                                                           /*! intiializes chosen SPI to default reset values */
        SPI_InitStructure.SPI_Direction = SPI_Direction_1Line_Tx;                       /*! specifies transfer direction in bidirectional mode -> Tx since stm writes to outside*/
        SPI_InitStructure.SPI_Mode = SPI_Mode_Master;                                   /*! Master since controller controls LED_MATRIX*/
        SPI_InitStructure.SPI_DataSize = SPI_DataSize_16b;                              /*! length of word which is used to communicate is 16b*/
        SPI_InitStructure.SPI_CPOL = SPI_CPOL_Low;                                      /*! clock polarity = 0 -> clock line idles low (default value) */
        SPI_InitStructure.SPI_CPHA = SPI_CPHA_1Edge;                                    /*! clock phase = 1 -> bits are sampled on rising clk edge (default value) */
        SPI_InitStructure.SPI_NSS = SPI_NSS_Soft;                                       /*! used since nss_input is not set by hw in master mode (constant high), makes it possible  to manage nss internal signal*/
        SPI_InitStructure.SPI_BaudRatePrescaler = SPI_BaudRatePrescaler_64;  
        SPI_InitStructure.SPI_FirstBit = SPI_FirstBit_MSB;                              /*! which bit is transmittet first (default value) */
        SPI_InitStructure.SPI_CRCPolynomial = 0;                                        /*! 0 bit since not used*/
        
        SPI_Init(SPI1, &SPI_InitStructure);                                             /*! initialized chosen instance with filled struct*/
        SPI_Cmd(SPI1, ENABLE);                                                          /*! activates specified SPi instance*/
    
    //NVIC config & start TIMER
    
        // Interrupt Channel for Timer 2 config
        NVIC_InitStructure.NVIC_IRQChannel=TIM2_IRQn;
        NVIC_InitStructure.NVIC_IRQChannelCmd=ENABLE;
        NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority=0;
        NVIC_InitStructure.NVIC_IRQChannelSubPriority=0;
        NVIC_Init(&NVIC_InitStructure);

    //LED_MATRIX init
    
        init_led_matrix();
				
				        
    //start TIM2
        TIM_Cmd(TIM2, ENABLE);
    
    //core program
        while(1)                                                                        /*!infinity loop waiting for interrupt*/
        {}
}

//Function used to write a data word to the LED_MATRIX over the SPI
void send_word_to_SPI(uint16_t address, uint16_t data) {
    uint16_t word = (address << 8) + data;                      /*! shift address 8 bit to the left since D11-D8 are address-bits and D7-D0 are data bits*/
    SPI_I2S_SendData16(SPI1, word);
    while(SPI_GetTransmissionFIFOStatus(SPI1) != SPI_TransmissionFIFOStatus_Empty);
}

//Function used to write the same word to specific addresses in all modules (used in the initialization of the led_matrix)
void send_same_word_to_all_modules(uint16_t address, uint16_t data) {
    GPIO_ResetBits(GPIOA, GPIO_Pin_4);

    for (int i = 0; i < 4; i++) {                               /*!  write all 4 words to the SPI (4 words = 1 matrix)*/
        send_word_to_SPI(address, data);
    }
    
    while(SPI_I2S_GetFlagStatus(SPI1, SPI_I2S_FLAG_BSY) == SET){
        //wait
    }
    
    GPIO_SetBits(GPIOA, GPIO_Pin_4);
        
    for (int i = 0; i < 5; i++) {                               /*! sets CSS high for the necessary 50ns*/ //TODO: if clk has to be changed
        //wait
    }
}

//Function used to initialize the LED_MATRIX
void init_led_matrix(void) {
    send_same_word_to_all_modules(0x0c, 0x01);                  /*! deactivate shutdown (page 7 in max7219)*/
    send_same_word_to_all_modules(0x09, 0x00);                  /*! deactivate decode mode by activating normal mode */
    send_same_word_to_all_modules(0x0b, 0x07);                  /*! set scan-limit to 7 */
}

//Function used to update the display with the new current_led_matrix
void send_current_matrix_to_modules(void) {
    for(int i = 0; i < 8; i++) { // for every column
        GPIO_ResetBits(GPIOA, GPIO_Pin_4);
        for(int j = 0; j < 4; j++) { // for every LED Module
            send_word_to_SPI(i+1, current_led_matrix[j][i]);
        }
        while(SPI_I2S_GetFlagStatus(SPI1, SPI_I2S_FLAG_BSY) == SET){}
        GPIO_SetBits(GPIOA, GPIO_Pin_4);
    }
}
//check if player and goal are at the same position
int check_game_over(void) {
    
    int game_over = 0;
		
		for (int i = 0; i < 2; i++){			
			if ((player_pos[0] == goal_pos[i][0]) && (player_pos[1] == goal_pos[i][1])) {
							game_over = 1;
			}
		}
    
    return game_over;
    
}

//add the passed position to the current_matrix
void add_pos_matrix(uint8_t pos[2]) {
   
    int x_cord = pos[0] -1;
    int y_cord = pos[1] -1;
    
    int m_num = 3-(y_cord / amount_of_fields_per_matrix);
    int c_pos = (y_cord % 8);
    
    uint8_t new_matrix_value = 1 << (c_pos);
    
    current_led_matrix[m_num][7-x_cord] = current_led_matrix[m_num][7-x_cord] | new_matrix_value;
}
//remove the passed position from the current_matrix
void remove_pos_matrix(uint8_t pos[2]) {
   
    int x_cord = pos[0] -1;
    int y_cord = pos[1] -1;
    
    int m_num = 3-(y_cord / amount_of_fields_per_matrix);
    int c_pos = (y_cord % 8);
    
    uint8_t new_matrix_value = 0 << (c_pos);
    
    current_led_matrix[m_num][7-x_cord] = new_matrix_value;

}
//sets new random position of the goal
void new_rndm_goal_position(void) {
    int rndm_x_pos = (ADC_input[0]) & 1;
    int rndm_y_pos = (ADC_input[1]) & 1;
	
	remove_pos_matrix(goal_pos[0]);
	remove_pos_matrix(goal_pos[1]);
			
	goal_pos[0][0] = (((goal_pos[0][0] << 1) | rndm_x_pos)& 0x7) +1;
	goal_pos[0][1] = (((goal_pos[0][1] << 1) | rndm_y_pos) & 0x1F) +1;
    
	if (rndm_x_pos == 0) {
    //goal is formed by 2 pixel beside each other  
			
        if (rndm_y_pos == 0) {
        //if horizontal next pixel should be to the left
            if (goal_pos[0][0] == 1) {
                    goal_pos[1][0] = goal_pos[0][0] +1;
            } else {
                    goal_pos[1][0] = goal_pos[0][0] -1;
            }
        } else {
        //if horizontal next pixel should be to the right
            if (goal_pos[0][0] == 8) {
                    goal_pos[1][0] = goal_pos[0][0] -1;
            } else {
                    goal_pos[1][0] = goal_pos[0][0] +1;
            }
        }
        //set other pixel to the same y-coord as the first one
        goal_pos[1][1] = goal_pos[0][1];
    } else {
    //goal is formed by 2 pixel on top of each other
    
        if (rndm_y_pos == 0) {
        //if vertical next pixel should be below
            if (goal_pos[0][1] == 1) {
                    goal_pos[1][1] = goal_pos[0][1] +1;
            } else {
                    goal_pos[1][1] = goal_pos[0][1] -1;
            }
        } else {
        //if vertical next pixel should be above
            if (goal_pos[0][1] == 32) {
                    goal_pos[1][1] = goal_pos[0][1] -1;
            } else {
                    goal_pos[1][1] = goal_pos[0][1] +1;
            }
        }
        //set other pixel to the same x-coord as the first one
        goal_pos[1][0] = goal_pos[0][0];
    }

    add_pos_matrix(goal_pos[0]);
	add_pos_matrix(goal_pos[1]);

} 

//Function which re-/ininitializes the game
void initialize_game(void) {
    remove_pos_matrix(player_pos);
		new_rndm_goal_position();
    player_pos[0] = 4;
    player_pos[1] = 16;
    add_pos_matrix(player_pos);
    send_current_matrix_to_modules();
}

//sets the direction of the player movement
void joy_stick_direction(void){
    						                
	double x_dir = ((double)ADC_input[0] * 3300.0/4096.0);
	double y_dir = ((double)ADC_input[1] * 3300.0/4096.0);
    //calculation: digital_value * v_ref / resolution (12b = 2pow(12) = 4096)

    if (x_dir > 3000) {
        //x_dir to the left
        movement_direction[0] = 1;
    } else if ((x_dir < 1700) && (x_dir > 1600)) {
        //x_dir in the middle
        movement_direction[0] = 0;
    } else if (x_dir < 300) {
        //x_dir to the right
        movement_direction[0] = -1;
    }

    if (y_dir > 3000) {
        //y_dir to the top
        movement_direction[1] = 1;
    } else if ((y_dir < 1700) && (y_dir > 1600)) {
        //y_dir in the middle
        movement_direction[1] = 0;
    } else if (y_dir < 300) {
        //y_dir to the bottom
        movement_direction[1] = -1;
    }
}

//moves the player into the calculated direction if it's possible
void player_movement(void) {

    int player_moves = 0;
    int new_player_pos[2] = {0,0};
		new_player_pos[0] = player_pos[0];
		new_player_pos[1] = player_pos[1];

    if (movement_direction[0] != 0) {
        //if player should move to the left or right
        if (!((player_pos[0] == 8) && (movement_direction[0] == 1)) && !((player_pos[0] == 1) && (movement_direction[0] == -1))) {
            //if player doesn't try to move outside of the field move him, otherwise don't
            new_player_pos[0] = player_pos[0] + movement_direction[0];
            player_moves = 1;
        }	
    }

    if (movement_direction[1] != 0) {
        //if player should move to the top or bottom
        if (!((player_pos[1] == 32) && (movement_direction[1] == 1)) &&  !((player_pos[1] == 1) && (movement_direction[1] == -1))) { 
            //if player doesn't try to move outside of the field move him, otherwise don't
            new_player_pos[1] = player_pos[1] + movement_direction[1];
            player_moves = 1;
        }
    }

    if (player_moves == 1) {
        remove_pos_matrix(player_pos);
        player_pos[0] = new_player_pos[0];
        player_pos[1] = new_player_pos[1];
        add_pos_matrix(player_pos);
				add_pos_matrix(goal_pos[0]);
				add_pos_matrix(goal_pos[1]);
        send_current_matrix_to_modules();
    }

}

//Function which sends data over the uart to a connected device
void send_uart_data(uint16_t data) {
    while(USART_GetFlagStatus(USART2, USART_FLAG_TXE)!=SET){};
    USART_SendData(USART2, data);
} 

//Timer 2 interrupt Handler
void TIM2_IRQHandler() {
    int button_B_val = GPIO_ReadInputDataBit(GPIOB, GPIO_Pin_3);
    int reset_game = 0;

    if ((!button_B_val) && button_released) {
        reset_game = 1;
        button_released = 0;
    } else if (button_B_val) {
        button_released = 1;
    }

    if ((reset_game) || (game_init == 1)) { /*! buttons are low active */
        //reset game
        game_init = 0;
        player_points = 0;
        send_uart_data(player_points);
        initialize_game();
    } else {
		
        if (check_game_over() == 1) {
            //if game over: increase points, send them over uart and re-init game
            player_points = player_points +1;
            send_uart_data(player_points);
            initialize_game();
            //TODO: send points to UART
        } else {
            //if game not over: move player into the direction pointet to by the joystick
            joy_stick_direction();
			player_movement();
        }
			}
		
    TIM_ClearITPendingBit(TIM2, TIM_IT_Update);
}


