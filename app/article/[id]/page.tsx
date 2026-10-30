import {ArticlePage} from '@/components/Site';
export default function Page({params}:{params:{id:string}}){return <ArticlePage id={params.id}/>}
