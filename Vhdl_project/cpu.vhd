-- Design de Computadores
-- developed by Pedro Azambuja e Eli Jose
-- file: cpu.vhd
-- date: date: 08/10/2019
library ieee;
use ieee.std_logic_1164.all;

entity cpu is
    generic (
		larguraBarramentoEnderecos	: natural := 8;
		larguraBarramentoDados		: natural := 8
    );
	port
    (
	 --===========================TESTE
	 LEDG : out std_logic_vector(6 downto 0);
	 --#################################
        clk			            : IN  STD_LOGIC;
        barramentoDadosEntrada	: IN STD_LOGIC_VECTOR(larguraBarramentoDados-1 DOWNTO 0);
        barramentoEnderecos		: OUT STD_LOGIC_VECTOR(larguraBarramentoEnderecos-1 DOWNTO 0);
	    barramentoDadosSaida	: OUT STD_LOGIC_VECTOR(larguraBarramentoDados-1 DOWNTO 0);
        readEnable		        : OUT STD_LOGIC;
        writeEnable		        : OUT STD_LOGIC
    );
end entity;

architecture estrutural of cpu is

	-- Declaração de sinais auxiliares
	signal ROM_instruction : STD_LOGIC_VECTOR(15 downto 0);
	signal bancoReg_out, ULA_inB, ULA_out, entrada_somador,dadoEscritaA, saida_somador, PC_out,MUXPC_out,MUXPC_inA : STD_LOGIC_VECTOR(larguraBarramentoDados-1 DOWNTO 0);
   signal muxJMP,wrReg, flagEqual,registerEqual,WR,RD : STD_LOGIC;
	signal opULA : STD_LOGIC_VECTOR(2 downto 0);
	signal muxMAIN : STD_LOGIC_VECTOR(1 downto 0);
	
    -- ...

begin

	    -- Instanciacao da ROM
	 ROM : entity work.romMif
	 port map(
	 Dado => ROM_instruction,
	 Endereco => PC_out
	 );
	 

    -- Instanciacao da Unidade de Controle
	 UC : entity work.UC
	 port map(
	 opcode => ROM_instruction(15 downto 13),
	 flagEqual => registerEqual,
	 muxJMP => muxJMP, -- entra no mux do pc
	 wrReg => wrReg, -- Seletor da escrita no banco de REG
	 muxMain => muxMAIN,
	 opULA => opULA,
	 RD => RD,
	 WR=>WR
	 
	 );

    -- Instanciação de Banco de Registradores
    BR : entity work.bancoRegistradores 
    generic map (
        larguraBarramentoDados    => larguraBarramentoDados
    )
	port map
	(
        clk	                => clk,
		enderecoA			=> ROM_instruction(12 downto 8),
        dadoEscritaA	    => dadoEscritaA,
        escreveA	        => wrReg,
        saidaA   		    => bancoReg_out
    );

    -- Instanciação do Program Counter
    PC : entity work.PC 
    -- generic map (
    -- );
	port map
	(
        clk	        => clk,
		input			=> MUXPC_out,
        output	    => PC_out
    );

    -- Instanciação do registrador que armazena a flag de comparacao
    registerFlag : entity work.registerFlag 
    -- generic map (
    -- );
	port map
	(
        clk	        => clk,
		input			=> flagEqual,
        output	    => registerEqual
    );
	 
	-- Instanciação de MUX do PC
    MUXPC : entity work.MuxPC
    generic map (
        larguraBarramentoDados    => larguraBarramentoDados
    )
	port map
	(
		inSomadorConstante			=> MUXPC_inA,
      inJump	        => ROM_instruction(7 downto 0),
        sel   		    => muxJMP,
		outMux	            => MUXPC_out
    );
    
	 	-- Instanciação de MUX do banco de reg
    MUXBancoReg : entity work.MuxBancoReg
    generic map (
        larguraBarramentoDados    => larguraBarramentoDados
    )
	port map
	(
		inA			=> ROM_instruction(7 downto 0),
		inB => ULA_out,
      inC	        => barramentoDadosEntrada,
        sel   		    => muxMAIN,
		outMux	            => dadoEscritaA
    );
    -- ...

    -- Instanciação de Somador com Constante
    SOMADOR : entity work.somadorConstante 
    generic map (
        larguraBarramentoDados    => larguraBarramentoDados
    )
	port map
	(
		inSomador			=> PC_out,
		outSomador	        => MUXPC_inA
    );
	 
	 
	 -- Instanciacao da ULA
	 ULA : entity work.ULA
	generic map (
        larguraBarramentoDados    => larguraBarramentoDados
    )
	port map
	(
		sel			=> opULA,
		inA	        => bancoReg_out,
		inB => ROM_instruction(7 downto 0),
		outULA => ULA_out,
		flagEqual => flagEqual
    );
	 
	 barramentoDadosSaida <= bancoReg_out;
	 barramentoEnderecos <= ROM_instruction(7 downto 0);
	 readEnable <= RD;
	 writeEnable <= WR;
    
	 --===TESTE
	 LEDG(6 downto 0) <= PC_out(6 downto 0);
	 --##############
	-- Completar com a instanciação de demais 
	-- componentes necessários;

end architecture;
