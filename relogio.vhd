-- Design de Computadores
-- file: relogio.vhd
-- date: 20/09/2019
-- Autores: Eli Jose e Pedro Azambuja
library ieee;
use ieee.std_logic_1164.all;

entity relogio is
	generic (
		larguraBarramentoEnderecos	: natural := 8;
		larguraBarramentoDados		: natural := 8;
		quantidadeChaves    		: natural := 2;
		quantidadeDisplays			: natural := 8
    );
	port
    (
		CLOCK_50 : IN STD_LOGIC;
		-- CHAVES
        SW : IN STD_LOGIC_VECTOR(quantidadeChaves-1 downto 0);
		-- DISPLAYS 7 SEG
		HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7 : OUT STD_LOGIC_VECTOR(6 downto 0) := "0000000";
		LEDG : out std_logic_vector(7 downto 0);
		LEDR : out std_logic_vector(17 downto 0) := "000000000000000000"
    );
end entity;

architecture estrutural of relogio is

	-- Sinais de barramentos
	signal barramentoEnderecos		: STD_LOGIC_VECTOR(larguraBarramentoEnderecos-1 DOWNTO 0);
	signal barramentoDadosEntrada	: STD_LOGIC_VECTOR(larguraBarramentoDados-1 DOWNTO 0);
	signal barramentoDadosSaida		: STD_LOGIC_VECTOR(larguraBarramentoDados-1 DOWNTO 0);
	
	-- Sinais de controle RD/WR
	signal readEnable				: STD_LOGIC;
	signal writeEnable				: STD_LOGIC;

	-- Sinais de habilitacao dos componentes
	signal LCD_US, LCD_DS, LCD_UM, LCD_DM, LCD_UH, LCD_DH	: STD_LOGIC;
	--signal habilitaChaves			: STD_LOGIC;
	signal habilita_BT : STD_LOGIC;
	signal reset: STD_LOGIC;
	-- Sinais auxiliares
	signal saidaDivisorGenerico		: STD_LOGIC_VECTOR(7 downto 0);
	signal switches : std_logic_vector(1 downto 0);

	signal tick : std_logic;
    signal contador : integer range 0 to 50000001 := 0;
	signal divisor : natural := 15000000;
	
begin


	  process(CLOCK_50)
    begin
        if rising_edge(CLOCK_50) then
					if contador >= divisor then
						contador <= 0;
						 tick <= not tick;
						 
					else
						 contador <= contador + 1;
			
			end if;
		  end if;
			end process;



	-- Instanciação da CPU
	CPU : entity work.cpu 
	port map
	(
	
	LEDG => LEDG(6 downto 0),
		clk						=> tick,
        barramentoDadosEntrada	=> saidaDivisorGenerico,
        barramentoEnderecos		=> barramentoEnderecos,
		barramentoDadosSaida	=> barramentoDadosSaida,
		readEnable				=> readEnable,
		writeEnable				=> writeEnable
	);
	
	-- Instanciação do Decodificador de Endereços
		-- A entidade do decodificador fica a criterio do grupo
		-- o portmap a seguir serve como exemplo
	DE : entity work.decoder 
	port map
	(
		endereco		=> barramentoEnderecos,
		readEnable		=> readEnable,
		writeEnable		=> writeEnable,
		LCD_US => LCD_US,
		LCD_DS => LCD_DS,
		LCD_UM => LCD_UM,
		LCD_DM => LCD_DM,
		LCD_UH => LCD_UH,
		LCD_DH => LCD_DH,
		IO_TEMPO => habilita_BT,
		CLEAR_TEMPO => reset
		
	);

	-- Instanciação do componente Divisor Genérico
		-- Componente da composição da Base de Tempo
		-- link: https://insper.blackboard.com/bbcswebdav/pid-622259-dt-content-rid-3999720_2/courses/201962.GRENGCOM_201561_0004.DESIGNCOMP_6ENGCOMPA/Atividades/vhdl/_componentesVHDL.html#exemplo-de-c%C3%B3digo-para-o-divisor
	BASE_TEMPO : entity work.baseTempo
	port map
	(
		clk				=> CLOCK_50,
		saida_clk		=> saidaDivisorGenerico,
		enable =>  habilita_BT,
		reset => reset,
		sel => switches
	);

	-- Instanciação de cada Display
	DISPLAY0 : entity work.display7Seg 
	port map
	(
		clk			=> CLOCK_50,
		dadoHex		=> barramentoDadosSaida(3 downto 0),
		habilita	=> LCD_US,
		saida7seg	=> HEX0
	);

	DISPLAY1 : entity work.display7Seg 
	port map
	(
		clk			=> CLOCK_50,
		dadoHex		=> barramentoDadosSaida(3 downto 0),
		habilita	=> LCD_DS,
		saida7seg	=> HEX1
	);
	DISPLAY2 : entity work.display7Seg 
	port map
	(
		clk			=> CLOCK_50,
		dadoHex		=> barramentoDadosSaida(3 downto 0),
		habilita	=> LCD_UM,
		saida7seg	=> HEX2
	);
	DISPLAY3 : entity work.display7Seg 
	port map
	(
		clk			=> CLOCK_50,
		dadoHex		=> barramentoDadosSaida(3 downto 0),
		habilita	=> LCD_DM,
		saida7seg	=> HEX3
	);
	DISPLAY4 : entity work.display7Seg 
	port map
	(
		clk			=> CLOCK_50,
		dadoHex		=> barramentoDadosSaida(3 downto 0),
		habilita	=> LCD_UH,
		saida7seg	=> HEX4
	);
	DISPLAY5 : entity work.display7Seg 
	port map
	(
		clk			=> CLOCK_50,
		dadoHex		=> barramentoDadosSaida(3 downto 0),
		habilita	=> LCD_DH,
		saida7seg	=> HEX5
	);


	-- Instanciação das Chaves
	CHAVES : entity work.switches 
	generic map (
        quantidadeChaves	=> quantidadeChaves
    )
	port map
	(
		SW => SW,
		saida	=> switches
	);
	
	
LEDG(7) <= saidaDivisorGenerico(0);

	-- componentes necessários

end architecture;
