library ieee;
use ieee.std_logic_1164.all;

entity terc4_encoder is
    port (
        data    : in  std_logic_vector(3 downto 0);
        encoded : out std_logic_vector(9 downto 0)
    );
end entity terc4_encoder;


architecture rtl of terc4_encoder is
begin

    process(all)
    begin
        case data is

            when "0000" => encoded <= "1010011100";
            when "0001" => encoded <= "1001100011";
            when "0010" => encoded <= "1011100100";
            when "0011" => encoded <= "1011100010";

            when "0100" => encoded <= "0101110001";
            when "0101" => encoded <= "0100011110";
            when "0110" => encoded <= "0110001110";
            when "0111" => encoded <= "0100111100";

            when "1000" => encoded <= "1011001100";
            when "1001" => encoded <= "0100111001";
            when "1010" => encoded <= "0110011100";
            when "1011" => encoded <= "1011000110";

            when "1100" => encoded <= "1010001110";
            when "1101" => encoded <= "1001110001";
            when "1110" => encoded <= "0101100011";
            when "1111" => encoded <= "1011000011";

            when others =>
                encoded <= (others => '0');

        end case;
    end process;

end architecture rtl;

