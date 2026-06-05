`timescale 1ns/1ps

module thermal_sensor_adc_ctrl (
    input  logic clk,
    input  logic rst_n,
    output logic adc_start,
    output logic adc_done,
    output logic [11:0] adc_data,
    output logic [11:0] alarm_threshold,
    output logic temp_alarm,
    output logic [11:0] current_temp,
    output logic thermal_irq
);

endmodule
