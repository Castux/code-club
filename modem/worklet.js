class DPSKEncoder extends AudioWorkletProcessor
{
    constructor()
    {
        super();

        this.carrier_freq = 440;
        this.samples_per_symbol = 100;
        this.bits_per_symbol = 1;
        this.sample_index = 0;
        this.queue = [];

        this.current_symbol = 0;
        this.previous_symbol = 0;

        this.port.onmessage = (event) =>
        {
            console.log(event.data);

            var cmd = event.data.cmd;
            var data = event.data.data;

            switch(cmd)
            {
                case "symbols":
                    this.queue = this.queue.concat(data);
                    break;
                case "sps":
                    this.samples_per_symbol = data;
                    break;
                case "bps":
                    this.bits_per_symbol = data;
                    break;
                case "carrier_freq":
                    this.carrier_freq = data;
                    break;
            }
        };
    }

    process(inputs, outputs, parameters)
    {
        const max_symbol = (1 << this.bits_per_symbol) - 1;

        const out = outputs[0];
        const twoPi = 2 * Math.PI;

        for (var i = 0 ; i < out[0].length ; i++)
        {
            var diff = (this.current_symbol - this.previous_symbol) % max_symbol;
            var phase = this.current_symbol / max_symbol;

            out[0][i] = Math.sin(phase);
            out[1][i] = Math.cos(phase);

            this.sample_index++;
            if(this.sample_index % this.samples_per_symbol == 0)
            {
                this.previous_symbol = this.current_symbol;
                this.current_symbol = this.queue.shift() ?? 0;
            }
        }

        return true;
    }
}

registerProcessor('dpsk-encoder', DPSKEncoder);
