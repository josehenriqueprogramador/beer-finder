<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Relations\Pivot;

class BeerStore extends Pivot
{
    protected $fillable = [
        'beer_id',
        'store_id',
        'price',
        'url',
        'promo_label',
    ];

    public function casts(): array
    {
        return [
            'price' => 'integer',
        ];
    }
}
