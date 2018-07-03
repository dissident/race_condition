# Race condition

## BAD CODE

With slow connection or higth server functioning capacity, we can get race condition.

### promocodes_controller.rb

```
class PromocodesController < ApplicationController
  before_action :authenticate_user!

  def activate
    @promocode = Promocode.new
  end

  def activation
    promocode = Promocode.where(code: promocode_params[:code], active: true).first
    if promocode.present? && promocode.activate(current_user)
      flash[:notice] = 'Code was activated'
    else
      flash[:error] = 'Bad promocode'
    end
    redirect_to :activate
  end

  private

  def promocode_params
    params.require(:promocode).permit(:code)
  end
end
```

### promocode.rb

```
class Promocode < ApplicationRecord
  has_one :user_transaction

  validates :code, uniqueness: true

  def self.generate(amount)
    code = SecureRandom.urlsafe_base64(8, false)
    create(code: code, amount: amount, active: true)
  end

  def activate(user)
    self.active = false
    self.user_transaction = UserTransaction.new(
      amount: amount,
      user_balance: user.user_balance
    )
    save!
  end
end
```

### user_transaction.rb

```
class UserTransaction < ApplicationRecord
  belongs_to :promocode
  belongs_to :user_balance

  after_create :change_balance

  private

  def change_balance
    balance = user_balance.amount + amount
    user_balance.update_attributes(amount: balance)
    self.finished = true
    save!
  end
end
```

## SOLUTION 1

### promocodes_controller.rb

Rails transactions are a way to ensure that a set of database operations will only occur if all of them succeed. Transaction is useless, the action is already wrapped in a transaction.

```
class PromocodesController < ApplicationController
  before_action :authenticate_user!

  def activate
    @promocode = Promocode.new
  end

  def activation
    promocode = Promocode.where(code: promocode_params[:code], active: true).first
    if promocode.present?
      promocode.transaction do
        promocode.activate(current_user)
        flash[:notice] = 'Code was activated'
      end
    else
      flash[:error] = 'Bad promocode'
    end
    redirect_to :activate
  end

  private

  def promocode_params
    params.require(:promocode).permit(:code)
  end
end
```

## SOLUTION 2

### user_transaction.rb

Very specific solution, we can't use it with our case.

```
class UserTransaction < ApplicationRecord
  belongs_to :promocode
  belongs_to :user_balance

  after_create :change_balance

  private

  def change_balance
    unless user_balance.transaction.last.amount == amount
      balance = user_balance.amount + amount
      user_balance.update_attributes(amount: balance)
      self.finished = true
      save!
    end
  end
end
```

## SOLUTION 3

The right way will be use Locking::Pessimistic. It provides support for row-level locking using SELECT … FOR UPDATE and other lock types. It will help to avoid race condition.

### promocodes_controller.rb

```
class PromocodesController < ApplicationController
  before_action :authenticate_user!

  def activate
    @promocode = Promocode.new
  end

  def activation
    promocode = Promocode.where(
      code: promocode_params[:code],
      active: true
    ).lock(true).first
    if promocode.present? && promocode.activate(current_user)
      flash[:notice] = 'Code was activated'
    else
      flash[:error] = 'Bad promocode'
    end
    redirect_to :activate
  end

  private

  def promocode_params
    params.require(:promocode).permit(:code)
  end
end
```

## SOLUTION 4

Async solution will work only in development environment, when we use 1 thread for query processing. On production with many threads it will be work incorrectly.

### promocodes_controller.rb

```
class PromocodesController < ApplicationController
  before_action :authenticate_user!

  def activate
    @promocode = Promocode.new
  end

  def activation
    promocode = Promocode.where(code: promocode_params[:code], active: true).first
    if promocode.present?
      PromocodActivationWorker.perform_async(current_user)
      flash[:notice] = 'Code was activated'
    else
      flash[:error] = 'Bad promocode'
    end
    redirect_to '/'
  end

  private

  def promocode_params
    params.require(:promocode).permit(:code)
  end
end
```
