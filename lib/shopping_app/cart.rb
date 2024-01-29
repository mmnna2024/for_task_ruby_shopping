require_relative "item_manager"
require_relative "ownable"

class Cart
  include Ownable
  include ItemManager

  def initialize(owner)
    self.owner = owner
    @items = []
  end

  def items
    # Cartにとってのitemsは自身の@itemsとしたいため、ItemManagerのitemsメソッドをオーバーライドします。
    # CartインスタンスがItemインスタンスを持つときは、オーナー権限の移譲をさせることなく、自身の@itemsに格納(Cart#add)するだけだからです。
    @items
  end

  def add(item)
    @items << item
  end

  def total_amount
    @items.sum(&:price)
  end

  def check_out
    return if owner.wallet.balance < total_amount#購入商品金額の合計が購入者ウォレットの金額を超えた場合処理をせずここに戻る
      @items.each do |item|
        owner.wallet.withdraw(item.price)#購入した商品の金額をwithdrawメソッドで所持金額から引いている
        item.owner.wallet.deposit(item.price)#購入者が購入した商品の合計金額をdepositメソッドを使って販売者の所持金額に追加する
        item.owner = owner#購入した商品のオーナーを販売者から購入者に移行
      end

    @items = []#カートを空にする
    end
  end
