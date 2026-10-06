module APB (
    input  logic        clk,
    input  logic        rst,

    // APB signals
    input  logic        psel,
    input  logic        penable,
    input  logic        pwrite,
    input  logic [7:0]  paddr,
    input  logic [31:0] pwdata,

    output logic [31:0] prdata,
    output logic        pready
);
    // Register Map
    localparam logic [7:0] ADDR_CONTROL = 8'h00;
    localparam logic [7:0] ADDR_DATA    = 8'h04;
    localparam logic [7:0] ADDR_STATUS  = 8'h08;

    // Registers
    logic [31:0] control_reg;
    logic [31:0] data_reg;
    logic [31:0] status_reg;

    // APB FSM
    typedef enum logic [1:0] {
        IDLE,
        SETUP,
        ACCESS
    } state_t;

    state_t current_state, next_state;

    // State Register
    always_ff @(posedge clk) begin
        if (rst)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // Next-State Logic
    always_comb begin
        next_state = current_state;

        case (current_state)

            IDLE: begin
                if (psel)
                    next_state = SETUP;
            end

            SETUP: begin
                if (psel && penable)
                    next_state = ACCESS;
                else if (!psel)
                    next_state = IDLE;
            end

            ACCESS: begin
                next_state = IDLE;
            end

            default: begin
                next_state = IDLE;
            end

        endcase
    end

    // Register Write
    always_ff @(posedge clk) begin
        if (rst) begin
            control_reg <= 32'b0;
            data_reg    <= 32'b0;
            status_reg  <= 32'b0;
        end
        else if (current_state == ACCESS &&
                 psel &&
                 penable &&
                 pwrite) begin

            case (paddr)

                ADDR_CONTROL:
                    control_reg <= pwdata;

                ADDR_DATA:
                    data_reg <= pwdata;

                default:
                    ; // Invalid address: no operation

            endcase
        end
    end
    // Read Data Mux
    always_comb begin
        prdata = 32'b0;

        if (current_state == ACCESS &&
            psel &&
            penable &&
            !pwrite) begin

            case (paddr)

                ADDR_CONTROL:
                    prdata = control_reg;

                ADDR_DATA:
                    prdata = data_reg;

                ADDR_STATUS:
                    prdata = status_reg;

                default:
                    prdata = 32'b0;

            endcase
        end
    end
    // APB Ready
    always_comb begin
        pready = (current_state == ACCESS);
    end

endmodule
