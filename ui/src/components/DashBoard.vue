<script>
export default {
    data() {
        return {
            data: {},
        }
    },
    props: {
        show: Boolean,
    },
    mounted() {
        window.addEventListener('message', (event)=>{
            const data = event.data
            switch(data.type) {
                case 'dashboard':
                    this.data = data.data
                break;
            }
        })
    },
}
</script>

<template>
    <div v-show="show">
        <div class="flex space-x-6 mb-8">
            <div class="flex flex-col grow bg-dashboard-darker p-6 rounded-xl border border-gray-700/50">
            <div class="flex items-center justify-between">
                <h3 class="text-gray-400">Queries today</h3>
                <div class="w-8 h-8 rounded-lg bg-accent/10 flex items-center justify-center">
                <i class="fa-solid fa-chart-simple text-accent"></i>
                </div>
            </div>
            <p class="text-3xl font-bold mt-2 text-white">{{ data.queries || '0' }}</p>
            <p class="text-sm text-gray-400 mt-2">Limit: {{ data.limit || '0' }}</p>
            </div>

            <div class="flex flex-col grow bg-dashboard-darker p-6 rounded-xl border border-gray-700/50">
                <div class="flex items-center justify-between">
                    <h3 class="text-gray-400">VPNs Blocked</h3>
                    <div class="w-8 h-8 rounded-lg bg-accent/10 flex items-center justify-center">
                        <i class="fa-solid fa-shield-halved text-accent"></i>
                    </div>
                </div>
                <p class="text-3xl font-bold mt-2 text-white">{{ data.vpn || '0' }}</p>
                <p class="text-sm text-gray-400 mt-2">Plan: {{ data.plan || 'Free' }}</p>
            </div>

            <div class="flex flex-col grow bg-dashboard-darker p-6 rounded-xl border border-gray-700/50">
                <div class="flex items-center justify-between">
                    <h3 class="text-gray-400">Proxies Detected</h3>
                    <div class="w-8 h-8 rounded-lg bg-accent/10 flex items-center justify-center">
                        <i class="fa-solid fa-shield-virus text-accent"></i>
                    </div>
                </div>
                <p class="text-3xl font-bold mt-2 text-white">{{ data.proxies || '0' }}</p>
                <p class="text-sm text-gray-400 mt-2">Total: {{ data.proxiesTotal || '0' }}</p>
            </div>

            <div class="flex flex-col grow bg-dashboard-darker p-6 rounded-xl border border-gray-700/50">
                <div class="flex items-center justify-between">
                    <h3 class="text-gray-400">Detection Rate</h3>
                    <div class="w-8 h-8 rounded-lg bg-accent/10 flex items-center justify-center">
                        <i class="fa-solid fa-percent text-accent"></i>
                    </div>
                </div>
                <p class="text-3xl font-bold mt-2 text-white">{{ data.detectionRate || '0.0%' }}</p>
                <p class="text-sm text-gray-400 mt-2">Burst Tokens: {{ data.burstTokens || '0' }}</p>
            </div>
        </div>

        <div class="flex flex-col bg-dashboard-darker rounded-xl border border-gray-700/50 p-6 mb-8">
            <h2 class="text-xl font-semibold mb-4 text-white">Today's Statistics</h2>
            <div class="flex flex-row w-full space-x-4">
                <div class="grow p-4 bg-gray-800/30 rounded-lg">
                    <h3 class="text-gray-400 text-sm">Undetected</h3>
                    <p class="text-2xl font-bold mt-1 text-white">{{ data.undetected || '0' }}</p>
                </div>
                <div class="grow p-4 bg-gray-800/30 rounded-lg">
                    <h3 class="text-gray-400 text-sm">Total Queries</h3>
                    <p class="text-2xl font-bold mt-1 text-white">{{ data.totalQueries || '0' }}</p>
                </div>
                <div class="grow p-4 bg-gray-800/30 rounded-lg">
                    <h3 class="text-gray-400 text-sm">Refused Queries</h3>
                    <p class="text-2xl font-bold mt-1 text-white">{{ data.refusedQueries || '0' }}</p>
                </div>
                <div class="grow p-4 bg-gray-800/30 rounded-lg">
                    <h3 class="text-gray-400 text-sm">Usage %</h3>
                    <p class="text-2xl font-bold mt-1 text-white">{{ data.usage || '0.0%' }}</p>
                </div>
            </div>
        </div>
    </div>
</template>