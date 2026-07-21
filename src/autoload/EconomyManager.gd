extends Node

var coins: int = 0
var crystals: int = 0

signal coins_changed(value: int)
signal crystals_changed(value: int)


func add_coins(amount: int):
    coins += amount
    coins_changed.emit(coins)


func spend_coins(amount: int) -> bool:
    if coins >= amount:
        coins -= amount
        coins_changed.emit(coins)
        return true
    return false


func add_crystals(amount: int):
    crystals += amount
    crystals_changed.emit(crystals)


func spend_crystals(amount: int) -> bool:
    if crystals >= amount:
        crystals -= amount
        crystals_changed.emit(crystals)
        return true
    return false


func reset_coins():
    coins = 0
    coins_changed.emit(coins)
