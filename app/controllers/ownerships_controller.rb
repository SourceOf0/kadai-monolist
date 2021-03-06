class OwnershipsController < ApplicationController
  
  # ログイン時のみ
  before_action :require_user_logged_in;
  
  def create
    # 見つかれば取得、見つからなければnew
    @item = Item.find_or_initialize_by(code: params[:item_code]);
    
    unless @item.persisted?
      # 保存されていなければ改めて情報を取得して保存
      results = RakutenWebService::Ichiba::Item.search(item_code: @item.code);
      @item = Item.new(read(results.first));
      @item.save;
    end
    
    if params[:type] == 'Want'
      current_user.want(@item);
      flash[:success] = '商品を Want しました。';
    elsif params[:type] == 'Have'
      current_user.have(@item);
      flash[:success] = '商品を Have しました。';
    end
    
    redirect_back(fallback_location: root_path);
  end


  def destroy
    @item = Item.find(params[:item_id]);
    if params[:type] == 'Want'
      current_user.unwant(@item);
      flash[:success] = '商品の Want を解除しました。';
    elsif params[:type] == 'Have'
      current_user.unhave(@item);
      flash[:success] = '商品の Have を解除しました。';
    end
    redirect_back(fallback_location: root_path);
  end
  
end
