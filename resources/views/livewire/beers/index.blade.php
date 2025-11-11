<div>
    <flux:main container="">
        <div class="flex flex-row items-center justify-between w-full">
            <div>
                <flux:heading size="xl">Cervejas</flux:heading>
                <flux:text class="mt-2 mb-6 text-base">Listagem de cervejas</flux:text>
            </div>

            <flux:button href="{{ route('beers.create') }}" icon="plus-circle">Criar nova cerveja</flux:button>
        </div>
    </flux:main>
</div>
